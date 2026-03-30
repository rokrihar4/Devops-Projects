Recreate your Docker Compose application stack for Kubernetes.

use Ingress (or as alternative it's successor Gateway API)
expose app via TLS on public IP with valid autorotated certificates  (e.g. with Nginx Ingress + certmanager or Traefik or ...)
minimum of 3 different services/containers for your application (besides Ingress, if you used a separate container as a reverse proxy in previous case; all system services/Pods don’t count)
at least one service must have minimum of 3 instances (generally speaking, try to make your solution HA)
create and use k8s YAML files for project deployments
use PersistentVolumes for storing data (where/when appropriate)
at least one image must be custom built/compiled by using multi-stage builds, final stage's image should be as minimal as possible for a chosen framework - same as for previous homework).
use a CICD to automatically build/tag/publish images from your git repository (use whatever you like: GH Actions, Gitlab CICD, ...).
you can use kompose or any other tool to convert your Docker compose files to K8s definitions, but don't forget to clean/modify them, or to adhere to k8s best practices!
create appropriate readiness/liveness probes (with its parameters tuned for your use case - describe briefly in README why you chose your particular values)
do a rolling update and blue/green deployment for at least one of your services in your solution. For demo purposes of rolling update, this chosen service cannot tolerate less replicas than declared, but your infrastructure can accommodate 1 extra Pod in each step of the rolling update. You can upgrade at most one Pod in single step. Differences between versions of your application stack can be minimal (e.g. different color of the text/background, updated text, etc.)
besides technical stuff also include in README:
instructions for running and
screenshots (or link to a video or recorded terminal session (asciinema or similar)) of demonstrating 0-downtime upgrade. E.g.rolling update and/or blue/green deployment of one of your services that has multiple active replicas.
Basically, you can just use your previous homework and "k8s"-ize it, with demo of readiness/liveness probes and with a focus on K8s app HA.

Grading will be done based on: originality and complexity of your problem/solution, adherence to best practices, quality of your documentation. You can also submit a simpler solution (so not complying with all requirements above), but that will impact your grade. You are also required to include a comprehensive technical README with screenshots of your solution in action. Don't forget to explicitly mention in README all extra things that you did in this project (non-mandatory stuff you perhaps did for extra credit, e.g. used GitOps with ArgoCD, created Helm chart, etc...). 

Submit a link to your GH repository and a snapshot of it as a compressed file.