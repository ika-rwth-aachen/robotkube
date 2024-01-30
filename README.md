# RobotKube

This repository accompanies our paper titled **RobotKube: Orchestrating Large-Scale Cooperative Multi-Robot Systems with Kubernetes and ROS**. In the repository, you will find instructions on how to reproduce a use case enabled by our approach, which combines

- **Kubernetes**,
- the **Robot Operating System (ROS)**, and our developed
- **event detector** and Kubernetes **application manger**.

For detailed information, please refer to the paper. It is currently under review and will be published afterwards.

> [!IMPORTANT]  
> This repository is open-sourced and maintained by the [**Institute for Automotive Engineering (ika) at RWTH Aachen University**](https://www.ika.rwth-aachen.de/).  
> **DevOps, Containerization and Orchestration of Software-Defined Vehicles** are some of many research topics within our [*Vehicle Intelligence & Automated Driving*](https://www.ika.rwth-aachen.de/en/competences/fields-of-research/vehicle-intelligence-automated-driving.html) domain.  
> If you would like to learn more about how we can support your DevOps or automated driving efforts, feel free to reach out to us!  
> &nbsp;&nbsp;&nbsp;&nbsp; *Timo Woopen - Manager Research Area Vehicle Intelligence & Automated Driving*  
> &nbsp;&nbsp;&nbsp;&nbsp; *+49 241 80 23549*  
> &nbsp;&nbsp;&nbsp;&nbsp; *timo.woopen@ika.rwth-aachen.de*  

## Content
- [Use Case Description](#use-case-description)
- [Paper and Citation](#paper-and-citation)
- [Repository Structure](#repository-structure)
- [Usage](#usage)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Advanced Monitoring](#advanced-monitoring)
  - [Interaction and Configuration](interaction-and-configuration)
- [Acknowledgements](#acknowledgements)

## Use Case Description

The use case involves fifteen connected vehicles, two of which are equipped with a lidar sensor. All vehicles send their poses to a cloud. When the lidar-equipped vehicles are near each other, the deployment of additional applications in the Kubernetes cluster is automatically triggered such that the two lidar-equipped vehicles start to additionally transmit their lidar point clouds to the cloud where they are stored in a database, along with the corresponding poses, e.g., allowing [collective learning](https://doi.org/10.1007/s38314-022-1405-9).

<p align="center">
  <img src="assets/robotkube_teaser.gif" alt="The video shows a section of the data upon which the use case is built. Poses of vehicles with no lidar sensor are visualized as green arrows. Poses of lidar-equipped vehicles are visualized as red arrows. The point clouds can be seen in blue and orange. The playback is sped up eightfold." width="70%">
</p>

The video shows a section of the data upon which the use case is built. Poses of vehicles with no lidar sensor are visualized as green arrows. Poses of lidar-equipped vehicles are visualized as red arrows. The point clouds can be seen in blue and orange. The playback is sped up eightfold.

## Paper and Citation

We hope our paper, data and code can help in your research. If this is the case, please [cite](https://github.com/ika-rwth-aachen/robotkube/blob/main/CITATION.cff) our paper and give this repository a star ⭐.

> **RobotKube: Orchestrating Large-Scale Cooperative Multi-Robot Systems with Kubernetes and ROS** ([arXiv](https://arxiv.org/abs/2308.07053), [Researchgate](https://www.researchgate.net/publication/373110880_RobotKube_Orchestrating_Large-Scale_Cooperative_Multi-Robot_Systems_with_Kubernetes_and_ROS))
>
> [Bastian Lampe](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/lampe.html), [Lennart Reiher](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/reiher.html), [Lukas Zanger](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/zanger.html), [Timo Woopen](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/woopen.html), [Raphael van Kempen](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/van-kempen.html), and [Lutz Eckstein](https://www.ika.rwth-aachen.de/de/institut/team/univ-prof-dr-ing-lutz-eckstein.html)  
> [Institute for Automotive Engineering (ika), RWTH Aachen University](https://www.ika.rwth-aachen.de/en/)
>
> <sup>*Abstract* – Modern cyber-physical systems (CPS) such as Cooperative Intelligent Transport Systems (C-ITS) are increasingly defined by the software which operates these systems. In practice, service-oriented software architectures can be employed, which may consist of containerized microservices running in a cluster comprised of robots and supporting infrastructure. These microservices need to be orchestrated dynamically according to ever changing requirements posed at the system. Additionally, these systems are embedded in DevOps processes aiming at continually updating and upgrading both the capabilities of CPS components and of the system as a whole. In this paper, we present RobotKube, an approach to orchestrating containerized microservices for large-scale cooperative multi-robot CPS based on Kubernetes. We describe how to automate the orchestration of software across a CPS, and include the possibility to monitor and selectively store relevant accruing data. In this context, we present two main components of such a system: an event detector capable of, e.g., requesting the deployment of additional applications, and an application manager capable of automatically configuring the required changes in the Kubernetes cluster. By combining the widely adopted Kubernetes platform with the Robot Operating System (ROS), we enable the use of standard tools and practices for developing, deploying, scaling, and monitoring microservices in C-ITS. We demonstrate and evaluate RobotKube in an exemplary and reproducible use case that we make publicly available at [github.com/ika-rwth-aachen/robotkube](https://github.com/ika-rwth-aachen/robotkube).</sup>

## Repository Structure

```
robotkube
├── assets                 # teaser video of use case  
├── data                   # use case data will be stored here
|     ├── db               # database with poses and point cloud metadata
|     └── large_data       # point clouds
└── kubernetes             # kubernetes related files
    ├── initial_deployment    # initial deployment resource definitions
    ├── ros_launchfiles       # initial deployment ros launch files 
    ├── ros_paramsfiles       # initial deployment ros parameter files 
    ├── templates             # templates for initial deployment resource definitions
    └── volumes               # persistent volumes and claims
```

## Usage
### Prerequisites

If not available already, install the following:

- [Ubuntu](https://ubuntu.com/download/desktop)
- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) 
- [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

We recommend *50 GB* of free disk space.

### Quick Start

1. Make sure prerequisites are installed and clone this repository:

    ```bash
    git clone https://github.com/ika-rwth-aachen/robotkube.git
    ```

2. Run the provided helper script [createCluster.sh](./createCluster.sh) to create the Kubernetes Cluster
    ```bash
    # robotkube
    ./createCluster.sh
    ```
    This might take a couple of minutes and also deletes any previous clusters named 'robotkube'.

3. Monitor the start-up and shut down of the different Kubernetes resources
    ```bash
    # robotkube
    watch -n 0.1 kubectl get all
    ```

4. In a new terminal, run the provided helper script [start.sh](./start.sh) to trigger the initial deployment.
    ```bash
    # robotkube
    ./start.sh
    ```
    This script will reset and reconfigure the cluster every time it is run. 

    You can now monitor the different Kubernetes resources in the first terminal. An initial deployment will be started. After a while, you can see the automatic deployment of the recording application, as described in the paper.

    In [data/db](data/db), you find the mongoDB database. It stores recorded poses and paths to corresponding point clouds which are stored in [data/large_data](data/large_data/).

5. If you want to get information on the different kinds of latencies involved in the use case, feel free to run
    ```bash
    # robotkube/latencies
    ./extract_timestamps.sh
    ```
    after an automatic deployment has finished to gather all relevant timestamps.

    You can then plot the result using

    ```bash
    # robotkube/latencies
    ./plot_latencies.py timestamps-all.csv
    ```

    in a suitable Python environment.

7. If you want to delete the KinD cluster, run
    ```bash
    kind delete cluster --name robotkube
    ```

### Advanced Monitoring

If you want to receive more information on what is happening in the cluster, you have the following options:

1. Monitor the current lidar-equipped vehicles' distance to each other
    ```bash
    kubectl logs --follow $(kubectl get pods | grep proximity-event-detector | awk '{print $1}') | grep "Distance between clients"
    ```

2. Monitor the time it takes to analyze the distances between all vehicles.
    ```bash
    kubectl logs --follow $(kubectl get pods | grep proximity-event-detector | awk '{print $1}') | grep "Analyzed rule"
    ```

3. Visualize the latest deployment request sent to the application manager from the proximity event detector via its operator plugin.
    ```bash
    kubectl exec --stdin --tty $(kubectl get pods | grep proximity-application-manager | awk '{print $1}') -- /bin/bash -c "source /docker-ros/ws/install/setup.bash && rostopic echo --clear /event_detector/proximity_based_deployment/deployment_request"
    ```
    You will only start seeing output after a while, when a new automatic deployment is requested.

4. Visualize the content of the database using [mongo-express](https://github.com/mongo-express/mongo-express) by running 
    ```bash
    # robotkube
    docker compose -f data/docker-compose.yml up
    ```
    and then opening [http://localhost:8081](http://localhost:8081) in your browser. Here, choose the `mongodb` database to get the following view:

    <img src=assets/robotkube_database.png alt="Image Description" width="300">

    You may take a look at the content of each collection.

    *Hint*: The deployments in the cluster must be stopped in order for the database visualization to work and you must have gathered data before.

### Interaction and Configuration

If you want to interact with the applications in the cluster or configure them differently, you have the following options:

1. Attach to one of the containers/pods in the cluster:
    ```bash
    kubectl exec -it <POD_NAME> -- bash
    ```
    Replace `POD_NAME` with the desired pod's name. To get a list of all available pod names, run
    
    ```bash
    kubectl get pods --no-headers -o custom-columns=":metadata.name"
    ```

2. You may change the [parameters](kubernetes/ros_paramsfiles/ed_params_k8s_rule.yaml) for the proximity event detector after you have created the cluster using `createCluster.sh`. These changes will be applied automatically when you run [start.sh](./start.sh) again

    ```bash
    # robotkube
    ./start.sh
    ```

## Acknowledgements

This research is accomplished within the research projects ”[AUTOtech.*agil*](https://www.ika.rwth-aachen.de/en/competences/projects/automated-driving/autotech-agil-en.html)” (FKZ 1IS22088A), ”[UNICAR*agil*](https://www.unicaragil.de/en/)” (FKZ 16EMO0284K), and ”[6GEM](https://www.6gem.de/en/)” (FKZ 16KISK036K). We acknowledge the financial support by the Federal Ministry of Education and Research of Germany (BMBF).
