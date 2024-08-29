import * as k8s from '@kubernetes/client-node';
import * as yaml from 'yaml';
import * as fs from 'fs';

const configurations = {
	cpu: ['1000m', '1500m', '2000m', '2500m', '3000m'],
	memory: ['2Gi', '2.5Gi', '3Gi', '4Gi', '6Gi'],
} as const;

const namespace = 'efrei-dev-local';

type CPU = (typeof configurations.cpu)[number];
type MEMORY = (typeof configurations.memory)[number];
type CONFIG = { cpu: CPU; memory: MEMORY };
type METRICS = {
	totalTime: number | 'N/A';
	totalCpuUsage: number | 'N/A';
	totalMemoryUsage: number | 'N/A';
	avgMemoryUsage: number | 'N/A';
	avgCpuUsage: number | 'N/A';
};

const prometheusUrl = `http://${process.env.K8S_NODE_IP}:30000/api/v1/query`;
const metricFile = 'metrics.json';

const kc = new k8s.KubeConfig();
kc.loadFromDefault();

async function createJob(manifest: string, config: CONFIG): Promise<string> {
	const k8sApi = kc.makeApiClient(k8s.BatchV1Api);

	// Load the YAML file
	const jobManifest = yaml.parse(manifest);

	// Modify CPU and memory requests
	jobManifest.spec.template.spec.containers[0].resources = {
		requests: {
			memory: config.memory,
			cpu: config.cpu,
		},
		limits: {
			memory: config.memory,
			cpu: config.cpu,
		},
	};

	// Give the job a unique name
	const jobName =
		`ml-training-job-${config.cpu}-${config.memory}`.toLocaleLowerCase();
	jobManifest.metadata.name = jobName;

	try {
		const response = await k8sApi.createNamespacedJob(namespace, jobManifest);
		const job = response.body;
		console.log(
			`Job created with CPU: ${config.cpu}, Memory: ${config.memory}, Name: ${job.metadata?.name}`
		);
	} catch (err: any) {
		console.error(`Error creating job ${jobName}:`, err.body);
	}

	return jobName;
}

async function getMetrics(jobName: string): Promise<METRICS> {
	const k8sApi = kc.makeApiClient(k8s.BatchV1Api);
	const response = await k8sApi.readNamespacedJobStatus(jobName, namespace);
	const job = response.body;

	if (job.status?.failed === 1) {
		console.error(
			`Could not collect metrics for job ${jobName} because it failed`
		);
		return {
			totalTime: 'N/A',
			totalCpuUsage: 'N/A',
			totalMemoryUsage: 'N/A',
			avgCpuUsage: 'N/A',
			avgMemoryUsage: 'N/A',
		};
	}

	const totalTime =
		(job.status?.completionTime?.getTime() ?? 0) -
		(job.status?.startTime?.getTime() ?? -1);

	const queries = {
		totalCpuUsage: `max(container_cpu_usage_seconds_total{pod=~"${jobName}.*"})`,
		totalMemoryUsage: `max(container_memory_usage_bytes{pod=~"${jobName}.*"})`,
		avgCpuUsage: `avg(rate(container_cpu_usage_seconds_total{pod=~"${jobName}.*"}[${totalTime / 1000}s]))`,
		avgMemoryUsage: `avg(rate(container_memory_usage_bytes{pod=~"${jobName}.*"}[${totalTime / 1000}s]))`,
	};

	const metrics: any = { totalTime };

	for (const [key, query] of Object.entries(queries)) {
		try {
			const response = await fetch(
				`${prometheusUrl}?query=${encodeURIComponent(query)}`
			);
			const data = await response.json();
			metrics[key] = data.data.result[0].value[1];
		} catch (error) {
			console.error(`Error fetching ${key} metrics:`, error);
		}
	}

	console.log(`Collected metrics for job ${jobName}`);

	return metrics;
}

function saveMetrics(config: CONFIG, newMetrics: METRICS) {
	const data = {
		config,
		metrics: newMetrics,
	};

	let metrics = [];
	if (fs.existsSync(metricFile)) {
		try {
			metrics = JSON.parse(fs.readFileSync(metricFile, 'utf8') || '[]');
		} catch (err: any) {
			console.error('Error reading metrics file:', err);
			metrics = [];
		}
	}

	metrics.push(data);

	try {
		fs.writeFileSync('metrics.json', JSON.stringify(metrics, null, 2));
	} catch (error) {
		console.error('Error writing metrics file:', error);
	}
}

function extractConfigFromJobName(jobName: string): CONFIG {
	const cpu = jobName.split('-').at(-2) as CPU;
	const memory = jobName.split('-').at(-1) as MEMORY;
	return { cpu, memory };
}

async function createAllJobsAndWaitForCompletion() {
	const manifest = fs.readFileSync('./job.yaml', 'utf8');
	const k8sApi = kc.makeApiClient(k8s.BatchV1Api);
	const jobNames = new Set<string>();

	for (const cpu of configurations.cpu) {
		for (const memory of configurations.memory) {
			const config = { cpu, memory };
			const jobName = await createJob(manifest, config);
			jobNames.add(jobName);
		}
	}

	while (jobNames.size > 0) {
		const response = await k8sApi.listNamespacedJob(namespace);
		const allJobs = response.body.items;
		const completedJobs = allJobs.filter(
			(job) => job.status?.succeeded && job.status.succeeded !== 0
		);

		console.log(`${completedJobs.length}/${allJobs.length} jobs completed`);

		for (const job of completedJobs) {
			const jobName = job.metadata?.name!;
			const metrics = await getMetrics(jobName);
			saveMetrics(extractConfigFromJobName(jobName), metrics);
			console.log(`Job ${jobName} completed and metrics collected.`);
			jobNames.delete(jobName);
			await k8sApi.deleteNamespacedJob(
				jobName,
				namespace,
				undefined,
				undefined,
				10, // wait 10s before deleting
				undefined,
				'Foreground' // immediately delete dependants
			);
		}

		await new Promise((resolve) => setTimeout(resolve, 100)); // Poll every 100ms
	}
}

async function createOneJobAndWaitForCompletion(
	manifest: string,
	config: CONFIG
) {
	const k8sApi = kc.makeApiClient(k8s.BatchV1Api);
	const jobName = await createJob(manifest, config);

	while (true) {
		const response = await k8sApi.readNamespacedJobStatus(jobName, namespace);
		const job = response.body;
		if ((job.status?.succeeded ?? 0) !== 0 || (job.status?.failed ?? 0) !== 0)
			break;

		await new Promise((resolve) => setTimeout(resolve, 100)); // Poll every 100ms
	}

	const metrics = await getMetrics(jobName);
	saveMetrics(extractConfigFromJobName(jobName), metrics);

	await k8sApi.deleteNamespacedJob(
		jobName,
		namespace,
		undefined,
		undefined,
		10, // wait 10s before deleting
		undefined,
		'Foreground' // immediately delete dependants
	);
}

async function createJobsAndWaitForCompletionOneByOne() {
	const manifest = fs.readFileSync('./job.yaml', 'utf8');

	for (const cpu of configurations.cpu) {
		for (const memory of configurations.memory) {
			const config = { cpu, memory };
			await createOneJobAndWaitForCompletion(manifest, config);
		}
	}
}

if (process.env.CONFIG_CPU && process.env.CONFIG_MEMORY) {
	const cpu = (process.env.CONFIG_CPU ?? '2000m') as CPU;
	const memory = (process.env.CONFIG_MEMORY ?? '4Gi') as MEMORY;
	const config = { cpu, memory };
	const manifest = fs.readFileSync('./job.yaml', 'utf8');

	createOneJobAndWaitForCompletion(manifest, config);
} else {
	createJobsAndWaitForCompletionOneByOne();
}
