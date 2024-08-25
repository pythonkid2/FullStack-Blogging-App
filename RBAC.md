# RBAC

Create Service Account, Role & Assign that role, And create a secret for Service Account and geenrate a Token

Creating Service Account – 

Create name space
```
kubectl create ns webapps
```
```
vi ServiceAccount.yml
```
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: webapps
```

```
kubectl apply -f ServiceAccount.yml

```
 

Create Role 

```
vi role.yml
```
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: webapps
rules:
  - apiGroups:
        - ""
        - apps
        - autoscaling
        - batch
        - extensions
        - policy
        - rbac.authorization.k8s.io
    resources:
      - pods
      - componentstatuses
      - configmaps
      - daemonsets
      - deployments
      - events
      - endpoints
      - horizontalpodautoscalers
      - ingress
      - jobs
      - limitranges
      - namespaces
      - nodes
      - secrets
      - pods
      - persistentvolumes
      - persistentvolumeclaims
      - resourcequotas
      - replicasets
      - replicationcontrollers
      - serviceaccounts
      - services
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
```
kubectl apply -f role.yml
```

### Bind the role to service account

```
vi rolebinding.yml
```
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: webapps 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role 
subjects:
- namespace: webapps 
  kind: ServiceAccount
  name: jenkins 
```
```
kubectl apply -f rolebinding.yml
```
Generate token using service account in the namespace

```
vi service-account-token.yml
```
```
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysecretname
  annotations:
    kubernetes.io/service-account.name: jenkins
```
```
kubectl apply -f service-account-token.yml -n webapps
```

```
kubectl describe secret mysecretname -n webapps
```

copy the token 

 

