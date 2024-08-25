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

![repo creation](https://github.com/user-attachments/assets/d2b362ed-1128-4b57-b46f-4f21cf989ca4)

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
![image](https://github.com/user-attachments/assets/75f9799f-1e91-4219-a1bd-7d9b8ac30507)

#### 1.8. Verify Push
- Ensure the code has been successfully pushed by checking the repository on GitHub.
![image](https://github.com/user-attachments/assets/0707d7ab-691b-4dbd-beb0-94a73da589ac)

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

![image](https://github.com/user-attachments/assets/79bd6932-bf64-4a51-8f2e-cfefe2566703)

![image](https://github.com/user-attachments/assets/75c5547d-4567-4f40-8b80-5f507f622acc)

![image](https://github.com/user-attachments/assets/322b9430-9bf8-41b8-9579-78e59ac4f2df)

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

![image](https://github.com/user-attachments/assets/8b2f4bdf-d5bf-4c32-af28-baf113c252d3)

![image](https://github.com/user-attachments/assets/cdd8d710-b69d-4559-b1ae-497c4dbf41ed)

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

![image](https://github.com/user-attachments/assets/370a6aa1-3429-4acf-82a1-a6ec4ee93190)
![image](https://github.com/user-attachments/assets/917e658f-a866-42b0-b355-93299adbd10c)

To generate a token in **SonarQube**, follow these steps:

1. **Log in** to your SonarQube instance.
2. Navigate to the top-right corner and click on **profile icon**.
3. From the dropdown, select **My Account**.
4. Go to the **Security** tab.
5. Under **Tokens**, click on **Generate Token**.
6. Enter a **name** for the token and click **Generate**.
7. Copy the token immediately, as you won't be able to view it again.

we can now use this token for authentication with tools  Jenkins or CI/CD pipelines.

- **Nexus**: 

![image](https://github.com/user-attachments/assets/3eeace34-c8bc-4760-a617-d02025c1b757)

   ```
  docker run -d --name nexus -p 8081:8081 sonatype/nexus3
  ```
  - Access Nexus at `http://<Nexus-Instance-Public-IP>:8081`.
  - Retrieve the initial admin password:
 
![image](https://github.com/user-attachments/assets/1e9442f4-13d6-44aa-9809-f8f7599968f4)

![image](https://github.com/user-attachments/assets/a2cc17fe-825b-4bd3-8c7b-a872cc2cc293)

  ```
  docker exec -it <container-id> /bin/bash
  cat /nexus-data/admin.password
  ```
![image](https://github.com/user-attachments/assets/125e4c4f-4bf4-4801-90a7-752f0eaf11ce)

### Step 3: Setup Trivy for Vulnerability Scanning
- SSH into the Jenkins instance and install Trivy by following the [official installation guide](https://aquasecurity.github.io/trivy/v0.18.3/installation/).

### Step 4: Set Up EKS Cluster Using Terraform

#### 4.1. Install Terraform and AWS CLI
- SSH into a new VM dedicated to running Terraform.
- Install Terraform following [HashiCorp’s guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
![image](https://github.com/user-attachments/assets/61a06ff5-fd5a-4315-8ef2-a8bc5f00c5aa)

- Install AWS CLI:
  ```
  sudo snap install aws-cli --classic
  ```
Verify that the AWS CLI installed correctly.
![image](https://github.com/user-attachments/assets/ce34309e-0fdb-42f1-a93d-eaabea3c41e9)

- Configure AWS CLI:
  ```
  aws configure
  ```

#### 4.2. Create Terraform Configuration Files
- Create a directory for Terraform files:
  ```
  mkdir terraform && cd terraform
  ```
- Add `main.tf`, `variables.tf`, and `outputs.tf`. Example files are available inGitHub repository.

Here’s the note for creating an IAM user and setting up AWS CLI:

---

### Communicating with AWS - Creating IAM User and Configuring CLI

1. **Create IAM User**
   - Go to **IAM** → **Users** → **Create User**
   - **User name**: `Mathew-Bloggingapp`
   - **Access**: Provide user access to AWS Management Console (optional, tick if needed)
   - Ensure the option **I want to create an IAM user** is ticked.
   
2. **Attach Policies to User**

![image](https://github.com/user-attachments/assets/08c3cc29-184f-49db-ab1b-065614a858c3)


3. **Generate Access Keys**
   - Navigate to the **Security credentials** tab.
   - Click on **Create access key**.
   - Choose **Use case**: `Command Line Interface (CLI)`.
   - Obtain the **Access key** and **Secret access key**.

4. **Configure AWS CLI on Terraform VM**
   - SSH into the Terraform VM.
   - Run:
     ```
     aws configure
     ```
   - Input the Access Key ID, Secret Access Key, and set default region and output format.
![image](https://github.com/user-attachments/assets/d7fce235-c649-4a7d-b2c0-a5473c5ac25f)

#### 4.3. Initialize and Apply Terraform Configuration
- Run the following commands to set up the EKS cluster:
  ```
  terraform init
  terraform plan
  terraform apply --auto-approve
  ```
![image](https://github.com/user-attachments/assets/2404644f-ab00-4957-abdb-ff28c673d692)
![image](https://github.com/user-attachments/assets/ae789fc3-4753-46a0-91f9-f5970e46df58)
![image](https://github.com/user-attachments/assets/a48c72ba-fe6d-431e-9bde-4fc5940d505f)


- Update the `kubeconfig` file to manage the EKS cluster:
  ```
  aws eks --region us-east-2 update-kubeconfig --name mega_project-cluster
  ```

I've reviewed the steps and arranged the content neatly, keeping the images intact. Here is the revised version with minor improvements and additional clarity:

---

### Step 5: Configure RBAC for Jenkins

1. **Create a ServiceAccount for Jenkins:**
   - Create a Kubernetes `ServiceAccount` for Jenkins.
   - Define **Roles** and **RoleBindings** to grant Jenkins access to Kubernetes resources.
   
   ![image](https://github.com/user-attachments/assets/219accc8-8638-4658-8fb1-922974468f7b)
   
2. **Generate Token Using ServiceAccount in Namespace:**
   - Create a token using the following YAML configuration:
   ```
   vi service-account-token.yml
   ```
   ```yaml
   apiVersion: v1
   kind: Secret
   type: kubernetes.io/service-account-token
   metadata:
     name: mysecretname
     annotations:
       kubernetes.io/service-account.name: jenkins
   ```
   - Apply the YAML configuration:
   ```
   kubectl apply -f service-account-token.yml -n webapps
   ```
   - Retrieve the token by describing the secret:
   ```
   kubectl describe secret mysecretname -n webapps
   ```
   - Copy the token for later use.

3. **Generate Docker Registry Secret for Jenkins:**
   - Use the following command to create a Kubernetes secret for Docker registry credentials:
   ```
   kubectl create secret docker-registry regcred \
   --docker-server=https://index.docker.io/v1/ \
   --docker-username=<your-username> \
   --docker-password=<your-password> \
   --namespace=webapps
   ```

---

### Docker Hub: Create Private Repository

1. Log in to Docker Hub.
2. Click on the **Repositories** tab on the left sidebar.
3. Click **Create Repository**.
4. Enter the **Repository Name**.
5. Set the visibility to **Private**.
6. Optionally, add a description.

   ![image](https://github.com/user-attachments/assets/64c4c9d5-b90d-4161-ad77-953eefb68fd9)

7. Click **Create**. Your private repository is now ready.

---

### Step 6: Jenkins Pipeline Setup

#### 6.1. Install Required Plugins in Jenkins

Install the following plugins in Jenkins to enable necessary features:
- **SonarQube Scanner**
- **Config File Provider**
- **Pipeline Maven Integration**
- **Maven Integration**
- **Docker Pipeline**
- **Pipeline: Stage View**
- **Kubernetes**
- **Kubernetes CLI**
- **Kubernetes Client API**
- **Kubernetes Credentials**
- **Docker**

#### 6.2. Configure Tools and Credentials

- In Jenkins, configure tools under **Manage Jenkins → Global Tool Configuration**. Set up Maven, SonarQube, and Docker:
  
   ![image](https://github.com/user-attachments/assets/f969d952-2d02-4ba0-926d-9c3490244a88)
   ![image](https://github.com/user-attachments/assets/e1ca2bf9-e18b-4cbf-a55f-849d193cc177)
   ![image](https://github.com/user-attachments/assets/dd02f54e-0b4b-49bd-a4e6-cc187172d07e)

- **Credentials:**
  - Go to **Dashboard → Manage Jenkins → Credentials**.
  - Use the Git token created earlier as the password:
   
    ![image](https://github.com/user-attachments/assets/937ff111-979a-4d4e-bf61-fb62e0f1bba4)
    ![image](https://github.com/user-attachments/assets/36fc1134-e1cb-4fdf-b0db-b33c407f64a1)
    ![image](https://github.com/user-attachments/assets/dfad4c11-ff72-46eb-86b3-252936a818d7)

  - Use SonarQube token as **Secret Text**.
  - For Docker Hub, use your **username** and **password** credentials:
   
    ![image](https://github.com/user-attachments/assets/1a7e76c9-343b-4129-aab2-abb5bb7198b8)

- **System Configuration:**
  - Go to **Manage Jenkins → System Configuration**.
   
    ![image](https://github.com/user-attachments/assets/17a9e094-1cae-47ff-ad40-c068ff3ae864)

- **Nexus Setup:**
  - Go to your GitHub repository, open the `pom.xml` file, and update it with Nexus URLs:
   
    ![image](https://github.com/user-attachments/assets/27119113-e381-469f-8ee1-398824186894)
    - Get the Nexus repository URLs and update the `pom.xml` in the **distributionManagement** section.
    - Allow **redeploy** in Nexus for both snapshots and releases:
   
      ![image](https://github.com/user-attachments/assets/8c38b86f-efa8-41e9-8335-46513deed641)
  - In Jenkins, go to **Manage Jenkins → Managed Files** and add **Global Maven settings.xml**.
  - Create a new config with:
    - **ID:** `maven-settings`
    - Edit the `servers` section to provide the Nexus **username** and **password**:
   
      ![image](https://github.com/user-attachments/assets/fef50a27-351f-4ad1-a2b4-b494d8972d06)

#### 6.3. Create Jenkins Pipeline

- Create a new Pipeline job in Jenkins.
- Define stages for **Git**, **SonarQube**, **Docker**, **Nexus**, and **Kubernetes** using pipeline syntax.
- Reference the appropriate GitHub repository for the pipeline script.

![image](https://github.com/user-attachments/assets/e5f2768c-8a8d-4fd1-ad9e-55263b532a1e)

Use pipeline syntax to generate pipeline -

For git -> git: Git
For SonarQube -> withSonarQubeEnv: Prepare SonarQube Scanner environment
Since we configured server in system we can use that 
For Nexus: With maven..
For Docker: withDockerRegistry: Sets up Docker registry endpoint
For K8: withKubeConfig: Configure Kubernetes CLI (kubectl)
![image](https://github.com/user-attachments/assets/639c8c50-cdf2-4de9-9bc2-cb6ae694d7af)

Success Pipeline 
![image](https://github.com/user-attachments/assets/8133a76d-e96a-451f-8079-f7d540046ad0)
![image](https://github.com/user-attachments/assets/dfdd42e4-c69c-4d2c-b7b7-178ff4bacbd2)
![image](https://github.com/user-attachments/assets/3025527f-fb6b-432a-b6d2-7a664771acc0)
![image](https://github.com/user-attachments/assets/55d10134-2218-44d5-ac6f-037b32d4a499)
![image](https://github.com/user-attachments/assets/b055b6c0-7315-4423-b3a5-bd7579b77206)
![image](https://github.com/user-attachments/assets/fa26ecea-2a7c-4918-8bcd-6b556af0fcdc)



### Step 7: Email Notifications Setup

### Email Setup for Jenkins

1. **Open Port 465**:
   - Ensure that port **465** is open in the security group associated with your Jenkins server to allow SMTP traffic.

2. **Generate Google App Password**:
   - Visit [Google App Passwords](https://myaccount.google.com/apppasswords).
   - Select **Mail** and your device, then generate a 16-character app password.
   - Copy this password for use in Jenkins.

3. **Configure Extended E-mail Notification in Jenkins**:
   - Go to **Manage Jenkins → Configure System → Extended E-mail Notification**.
   - Set the SMTP server to:
     ```
     smtp.gmail.com
     ```
   - Add credentials:
     - Use your Gmail address as the **username** (`mjcmathew@gmail.com`).
     - Use the **app password** generated earlier as the password.
   - Enable **Use SSL**.

4. **Configure Basic E-mail Notification in Jenkins**:
   - Scroll down to **E-mail Notification** in the same configuration page.
   - Set the SMTP server to:
     ```
     smtp.gmail.com
     ```
   - Click **Advanced** and check **Use SMTP Authentication**:
     - **Username**: `mjcmathew@gmail.com`
     - **Password**: Use the **app password** generated earlier.
   - Set the SMTP port to:
     ```
     465
     ```
   - Ensure **SSL** is enabled.

5. **Save and Test**:
   - Save your configuration.
   - Test the email setup by sending a test email from the **Extended E-mail Notification** section to confirm that Jenkins can send emails.

![image](https://github.com/user-attachments/assets/17b08fe5-09e0-42cf-9775-17a3d0b376cc)

### Step 8: Domain Mapping with GoDaddy

- Map domain to Jenkins or other services using GoDaddy. Configure DNS settings to point to the correct IP addresses of your infrastructure.
![image](https://github.com/user-attachments/assets/033acae7-0eed-4ea0-90f8-7f13a4db4be1)

![image](https://github.com/user-attachments/assets/4f86afe9-1561-44ad-99b9-8dccf0f9f9bd)

```
nslookup www.mathewdemo.shop
```

![image](https://github.com/user-attachments/assets/91032cc8-8397-40d2-863f-46592f16ecca)


![image](https://github.com/user-attachments/assets/27f76f22-2c37-4afa-a86f-a725d2c59980)

![image](https://github.com/user-attachments/assets/fa5c9c32-9368-4d9b-9f3f-d7fed7e12bdd)


### **Step 9: Monitoring with Prometheus and Grafana**

#### 1. **Install Prometheus**
- Download and install Prometheus:

   ```
   wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz
   tar -xvf prometheus-2.53.2.linux-amd64.tar.gz
   ./prometheus &
   ```
   ![Prometheus Setup](https://github.com/user-attachments/assets/867a0012-d066-4a63-99da-56efacac8e48)

#### 2. **Install Blackbox Exporter**
- Download and install Blackbox Exporter for endpoint monitoring:

   ```
   wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
   tar -xvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
   ./blackbox_exporter &
   ```
   ![Blackbox Exporter Setup](https://github.com/user-attachments/assets/2b3c1209-2a9e-460d-b2de-1f50a07be48a)

- Add **Blackbox Exporter** as a job in Prometheus' configuration file (`prometheus.yml`). For example:

  ```
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://example.com
        - http://another-site.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115  # Blackbox Exporter address
  ```

#### 3. **Managing Prometheus Process**
- To check the **Prometheus process ID**, run:
  
   ```
   pgrep prometheus
   ```

- To kill and restart Prometheus:
  
   ```
   kill <process_id>
   ./prometheus &
   ```

#### 4. **Verify Targets in Prometheus**
- Once Blackbox Exporter is running, check the **Prometheus targets** to verify that Blackbox Exporter is added and active.

  ![Prometheus Targets](https://github.com/user-attachments/assets/d1399e10-1f5e-419b-8264-0af440e48fe5)
  
  ![Blackbox Exporter in Prometheus](https://github.com/user-attachments/assets/475e0ec2-fdd7-4eb6-b5b2-54fa0f6aac4e)


Got it! I'll make sure not to remove any of the images provided. Here's the organized guide for **Grafana installation and configuration**:

---

### **Step 10: Install and Configure Grafana**

#### 3. **Install Grafana**
- Download and install **Grafana** from the official website or your system's package manager. Once installed, start the Grafana service.

---

#### 4. **Connect Prometheus as a Data Source**

1. **Log in to Grafana**:
   - Access Grafana via your browser using the URL:  
     ```
     http://<your-server-ip>:3000
     ```

2. **Add Prometheus as a Data Source**:
   - Navigate to **Home → Connections → Data Sources → Add Data Source**.
   - Select **Prometheus** from the list of data sources.

   ![image](https://github.com/user-attachments/assets/c847fe57-8361-4bd8-be28-50173f67bf0f)

3. **Configure Prometheus**:
   - Set the **Prometheus URL** (e.g., `http://localhost:9090`).

   ![image](https://github.com/user-attachments/assets/48123006-816d-4262-b34e-f5f1998cf03c)

4. **Test the Connection**:
   - Click the **Save & Test** button to ensure Grafana can communicate with Prometheus.

   ![image](https://github.com/user-attachments/assets/10985106-c96a-4dd7-9b16-31d05a3f8433)

---

#### 5. **Import Grafana Dashboard**

1. **Navigate to Dashboards**:
   - Go to **Dashboards → Import Dashboard**.

2. **Import Dashboard ID 7587**:
   - Enter the dashboard ID `7587` in the **Import via Grafana.com** field and click **Load**.

   ![image](https://github.com/user-attachments/assets/b26e1705-7c74-4bd7-a292-3d43e43079ca)

3. **Configure Data Source**:
   - Select **Prometheus** as the data source for the dashboard.

   ![image](https://github.com/user-attachments/assets/2678360c-e2d5-4047-bbe0-8cc24601c7e7)

4. **Dashboards Available**:
   - Your **Grafana dashboard** will now be available, showing Prometheus metrics.

   ![image](https://github.com/user-attachments/assets/10985106-c96a-4dd7-9b16-31d05a3f8433)
![image](https://github.com/user-attachments/assets/578b5a4f-3dd2-42bf-9c67-792b7ed55933)

