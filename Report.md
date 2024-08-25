# FULLSTACK-BLOGGING-APP

### By Mathew Joseph

## Project Overview

![flow chart](https://github.com/user-attachments/assets/7ce42918-38d0-4491-976d-89478363feaa)

This project automates the following DevOps workflow:

- **Code Push to GitHub**
- **Trigger Jenkins Pipeline**
- **Compile Source Code**
- **Run Unit Tests**
- **Vulnerability Scan with Aqua Trivy**
- **Code Quality & Coverage with SonarQube**
- **Build JAR with Maven**
- **Push JAR to Nexus Repository**
- **Build Docker Image**
- **Scan Docker Image**
- **Push Docker Image to Private Registry**
- **Deploy Application to EKS**
- **Create Kubernetes Secret for Private Registry**
- **Setup Mail Notification for the Pipeline**
- **Map Domain with GoDaddy**
- **Monitor with Blackbox Exporter, Prometheus, Grafana**

### Step 1: Code Push to GitHub

#### 1.1. Create a GitHub Repository
- Log in to GitHub and create a new repository named `FullStack-Blogging-App`.
- Choose appropriate settings (public/private) as needed.

#### 1.2. Clone the Repository to Local System
- Clone the repository to your local development environment:
  ```
  git clone https://github.com/pythonkid2/FullStack-Blogging-App.git
  ```
- Navigate to the repository directory:
  ```
  cd FullStack-Blogging-App
  ```

#### 1.3. Add Application Source Code
- Develop or add your application source code into the appropriate directories within the repository.

#### 1.4. Add Terraform Configuration Files
- Write and add Terraform configuration files for provisioning the EKS cluster.

#### 1.5. Stage the Changes
- Use the following command to stage the application source code and Terraform files:
  ```
  git add .
  ```

#### 1.6. Commit the Changes
- Commit the changes with a descriptive message:
  ```
  git commit -m "Added application source code and Terraform configuration for EKS"
  ```

#### 1.7. Push the Code to GitHub
- Push the committed changes to the GitHub repository:
  ```
  git push origin main
  ```

#### 1.8. Verify Push
- Ensure the code has been successfully pushed by checking the repository on GitHub.

#### Generate GitHub Token for Jenkins Integration
1. Log in to GitHub → Go to **Settings** → **Developer Settings** → **Personal Access Tokens** → **Tokens (Classic)** → **Generate new token**.
2. Select appropriate scopes like `repo`, `admin:repo_hook` for Jenkins.
3. Copy the token and store it securely for use in Jenkins.

### Step 2: Create VMs and Set Up Jenkins, SonarQube, and Nexus

#### 2.1. Create VMs on AWS
- Launch EC2 instances for Jenkins, SonarQube, and Nexus. Use the following specifications:
  - **AMI**: Ubuntu 24.04 LTS
  - **Instance Type**: t2.medium (2 vCPUs, 4 GiB RAM)
  - **Storage**: 15 GB for each instance.
  - **Security Groups**:
    - SSH (22)
    - Custom TCP (9000) for SonarQube
    - Custom TCP (8081) for Nexus

#### 2.2. Install Jenkins on EC2 Instance
- SSH into the Jenkins instance:
  ```
  ssh -i /path/to/key.pem ubuntu@<Jenkins-Instance-Public-IP>
  ```
- Update the system and install Java:
  ```
  sudo apt update
  sudo apt install fontconfig openjdk-17-jre -y
  ```
- Follow the [official Jenkins documentation](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu) to install Jenkins.
- Once installed, access Jenkins at `http://<Jenkins-Instance-Public-IP>:8080` and retrieve the initial admin password:
  ```
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```

#### 2.3. Install Docker on EC2 Instances
- Install Docker on the SonarQube and Nexus instances using [official Docker installation documentation](https://docs.docker.com/engine/install/ubuntu/).
  ```
  sudo chmod 666 /var/run/docker.sock
  ```
  > _Note: A more secure approach is to add your user to the Docker group:_
  ```
  sudo usermod -aG docker $USER
  ```

#### 2.4. Run SonarQube and Nexus in Docker
- **SonarQube**: 
  ```
  docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
  ```
  - Access SonarQube at `http://<SonarQube-Instance-Public-IP>:9000`.
  - Default login: `admin/admin`.

- **Nexus**: 
  ```
  docker run -d --name nexus -p 8081:8081 sonatype/nexus3
  ```
  - Access Nexus at `http://<Nexus-Instance-Public-IP>:8081`.
  - Retrieve the initial admin password:
  ```
  docker exec -it <container-id> /bin/bash
  cat /nexus-data/admin.password
  ```

### Step 3: Setup Trivy for Vulnerability Scanning
- SSH into the Jenkins instance and install Trivy by following the [official installation guide](https://aquasecurity.github.io/trivy/v0.18.3/installation/).

### Step 4: Set Up EKS Cluster Using Terraform
#### 4.1. Install Terraform and AWS CLI
- SSH into a new VM dedicated to running Terraform.
- Install Terraform following [HashiCorp’s guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
- Install AWS CLI:
  ```
  sudo snap install aws-cli --classic
  ```
- Configure AWS CLI:
  ```
  aws configure
  ```

#### 4.2. Create Terraform Configuration Files
- Create a directory for Terraform files:
  ```
  mkdir terraform && cd terraform
  ```
- Add `main.tf`, `variables.tf`, and `outputs.tf`. Example files are available in your GitHub repository.

#### 4.3. Initialize and Apply Terraform Configuration
- Run the following commands to set up the EKS cluster:
  ```
  terraform init
  terraform plan
  terraform apply --auto-approve
  ```
- Update the `kubeconfig` file to manage the EKS cluster:
  ```
  aws eks --region us-east-2 update-kubeconfig --name mega_project-cluster
  ```

### Step 5: Configure RBAC for Jenkins

1. Create a Kubernetes **ServiceAccount** for Jenkins.
2. Define **Roles** and **RoleBindings** to grant Jenkins access to Kubernetes resources.
3. Generate a Kubernetes secret for Docker registry credentials using the command:
   ```
   kubectl create secret docker-registry regcred \
   --docker-server=https://index.docker.io/v1/ \
   --docker-username=<your-username> \
   --docker-password=<your-password> \
   --namespace=webapps
   ```

### Step 6: Jenkins Pipeline Setup

#### 6.1. Install Required Plugins in Jenkins
- Install the following plugins: SonarQube Scanner, Config File Provider, Pipeline Maven Integration, Docker Pipeline, Kubernetes, etc.

#### 6.2. Configure Tools and Credentials
- In Jenkins, configure tools under **Manage Jenkins → Tools**. Set up Maven, SonarQube, Docker, and Kubernetes CLI.

#### 6.3. Create Jenkins Pipeline
- Create a new Pipeline in Jenkins.
- Use pipeline syntax to define stages for Git, SonarQube, Docker, Nexus, and Kubernetes. Reference the GitHub repository for the pipeline script.

### Step 7: Email Notifications

- Set up email notifications using Gmail’s SMTP server. Follow these steps:
  - SMTP server: `smtp.gmail.com`
  - Port: `465`
  - Enable SSL
  - Use app-specific passwords generated from your Google account.

### Step 8: Domain Mapping with GoDaddy
- Map your domain with GoDaddy by configuring DNS settings to point to the correct IP addresses.

### Step 9: Monitoring with Prometheus and Grafana

1. **Install Prometheus**:
   ```
   wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz
   tar -xvf prometheus-2.53.2.linux-amd64.tar.gz
   ./prometheus &
   ```
2. **Install Blackbox Exporter** for monitoring:
   ```
   wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
   tar -xvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
   ./blackbox_exporter &
   ```
   - Add Blackbox Exporter job to Prometheus’ configuration file.

3. **Install Grafana** and configure it to display Prometheus metrics. Import dashboard 7587 for visualization.
