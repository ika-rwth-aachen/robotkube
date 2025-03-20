# RobotKube
<img src="assets/robotkube_logo.png" height=180 align="right">

This repository accompanies our paper titled **RobotKube: Orchestrating Large-Scale Cooperative Multi-Robot Systems with Kubernetes and ROS** and further future publications.

The approach combines **Kubernetes** with the **Robot Operating System (ROS)** and our developed software, an **event detector** and an **application manger** for Kubernetes. 

Since the initial release of this repository, the use case has been updated to **ROS 2**.

> [!IMPORTANT]  
> This repository is open-sourced and maintained by the [**Institute for Automotive Engineering (ika) at RWTH Aachen University**](https://www.ika.rwth-aachen.de/).  
> We cover a wide variety of research topics within our [*Vehicle Intelligence & Automated Driving*](https://www.ika.rwth-aachen.de/en/competences/fields-of-research/vehicle-intelligence-automated-driving.html) domain.  
> If you would like to learn more about how we can support your automated driving or robotics efforts, feel free to reach out to us!  
> :email: ***opensource@ika.rwth-aachen.de***

## Paper and Citation

We hope our paper, data and code can help in your research. If this is the case, please cite our paper and give this repository a star ⭐.

### RobotKube: Orchestrating Large-Scale Cooperative Multi-Robot Systems with Kubernetes and ROS

<details>
<summary>BibTeX</summary>

```
@INPROCEEDINGS{Lampe2023RobotKube,
  author={Lampe, Bastian and Reiher, Lennart and Zanger, Lukas and Woopen, Timo and van Kempen, Raphael and Eckstein, Lutz},
  booktitle={2023 IEEE 26th International Conference on Intelligent Transportation Systems (ITSC)}, 
  title={RobotKube: Orchestrating Large-Scale Cooperative Multi-Robot Systems with Kubernetes and ROS}, 
  year={2023},
  pages={2719-2725},
  doi={10.1109/ITSC57777.2023.10422370}}
```
</details>

> **RobotKube: Orchestrating Large-Scale Cooperative Multi-Robot Systems with Kubernetes and ROS** ([IEEE Xplore](https://ieeexplore.ieee.org/document/10422370), [arXiv](https://arxiv.org/abs/2308.07053))
>
> [Bastian Lampe](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/lampe.html), [Lennart Reiher](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/reiher.html), [Lukas Zanger](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/zanger.html), [Timo Woopen](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/woopen.html), [Raphael van Kempen](https://www.ika.rwth-aachen.de/de/institut/team/fahrzeugintelligenz-automatisiertes-fahren/van-kempen.html), and [Lutz Eckstein](https://www.ika.rwth-aachen.de/de/institut/team/univ-prof-dr-ing-lutz-eckstein.html)
>
> [Institute for Automotive Engineering (ika), RWTH Aachen University](https://www.ika.rwth-aachen.de/en/)
> 
> <sup>*Abstract* – Modern cyber-physical systems (CPS) such as Cooperative Intelligent Transport Systems (C-ITS) are increasingly defined by the software which operates these systems. In practice, service-oriented software architectures can be employed, which may consist of containerized microservices running in a cluster comprised of robots and supporting infrastructure. These microservices need to be orchestrated dynamically according to ever changing requirements posed at the system. Additionally, these systems are embedded in DevOps processes aiming at continually updating and upgrading both the capabilities of CPS components and of the system as a whole. In this paper, we present RobotKube, an approach to orchestrating containerized microservices for large-scale cooperative multi-robot CPS based on Kubernetes. We describe how to automate the orchestration of software across a CPS, and include the possibility to monitor and selectively store relevant accruing data. In this context, we present two main components of such a system: an event detector capable of, e.g., requesting the deployment of additional applications, and an application manager capable of automatically configuring the required changes in the Kubernetes cluster. By combining the widely adopted Kubernetes platform with the Robot Operating System (ROS), we enable the use of standard tools and practices for developing, deploying, scaling, and monitoring microservices in C-ITS. We demonstrate and evaluate RobotKube in an exemplary and reproducible use case that we make publicly available at [github.com/ika-rwth-aachen/robotkube](https://github.com/ika-rwth-aachen/robotkube).</sup>

## Use Cases
We aim to provide reproducible use cases that demonstrate the capabilities of RobotKube. In the subfolder [use-cases](./use-cases/) of the repository, you will find **instructions** on how to **reproduce** the **use cases**.

| Use Case | Description |
| --- | --- |
| [Pose Point Cloud DB Recording](./use-cases/pose-point-cloud-db-recording) | Use case developed for the original RobotKube paper: In case of proximity of two vehicles providing point clouds, record poses and point clouds to database using Event Detector with Database Recording Plugin |
| ... | ... |

## Acknowledgements

This research is accomplished within the research projects ”[autotech.agil](https://www.autotechagil.de/)” (FKZ 1IS22088A), ”[UNICAR*agil*](https://www.unicaragil.de/en/)” (FKZ 16EMO0284K), and ”[6GEM](https://www.6gem.de/en/)” (FKZ 16KISK036K). We acknowledge the financial support by the Federal Ministry of Education and Research of Germany (BMBF).