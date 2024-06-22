<div align="center" id="top"> 
  <img src="./kind.png" alt="Kind Tf" />

&#xa0;

</div>

<h1 align="center">Kubernetes in Docker (KinD) with Terraform</h1>

<p align="center">
  <img alt="Github top language" src="https://img.shields.io/github/languages/top/devenes/kind-terraform?color=56BEB8">
  <img alt="Github language count" src="https://img.shields.io/github/languages/count/devenes/kind-terraform?color=56BEB8">
  <img alt="Repository size" src="https://img.shields.io/github/repo-size/devenes/kind-terraform?color=56BEB8">
  <img alt="License" src="https://img.shields.io/github/license/devenes/kind-terraform?color=56BEB8">
</p>


<p align="center">
  <a href="#dart-about">About</a> &#xa0; | &#xa0; 
  <a href="#rocket-technologies">Technologies</a> &#xa0; | &#xa0;
  <a href="#white_check_mark-requirements">Requirements</a> &#xa0; | &#xa0;
  <a href="#checkered_flag-starting">Starting</a> &#xa0; | &#xa0;
  <a href="#memo-license">License</a> &#xa0; | &#xa0;
</p>

<br>

## 🎯 About

This project is a simple example of how to use Terraform to create a Kubernetes cluster in Docker using Kind and install ArgoCD to the Management Cluster.

## Technologies

The following tools were used in this project:

- [Terraform](https://www.terraform.io/)
- [Kind](https://kind.sigs.k8s.io/)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)

## Requirements
The following has to be installed before starting
 - [Git](https://git-scm.com)
 - [Docker](https://www.docker.com/)
 - [KinD](https://kind.sigs.k8s.io/)
 - [Terraform](https://www.terraform.io/)

## Starting

Clone this project

```bash
git clone https://github.com/muecahit94/gitops-at-scale
```

Access the project folder

```bash
cd gitops-at-scale/IaC
```

Inıtialize Terraform

```bash
terraform init
```

Plan the Terraform execution

```bash
terraform plan
```

Apply the Terraform execution

```bash
terraform apply
```

After apply you need to set three variables:

Host IP-Address: set your PC/Laptops IP-Address

ArgoCD admin password, need to be bcrypt hashed: 
```bash
htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'
```

Stage Count: Number of stages/clusters that you want

When the installation was successful, ArgoCD should be available with http://localhost:30080/, user: **admin**, password: $ARGO_PWD


## License

This project is under license from MIT. For more details, see the [LICENSE](LICENSE) file.

&#xa0;

<a href="#top">⬆️ Back to top</a>
