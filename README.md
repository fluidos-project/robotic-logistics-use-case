# Robotic logistics

Kubernetes manifest files for simulation of a Robotnik RB-theron on ROS2

## Requirements

- Kubernetes >=1.25
- Ingress controller
- kubectl

## Deployment

```bash
git clone git@github.com:fluidos-project/WP7_robotic_logistics.git
cd WP7_robotic_logistics/k8s
kubectl create namespace robots
kubectl apply -f pseudo-chart
```

### nginx ingress controller install
```bash
cd helm-ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade \
 --install ingress-nginx ingress-nginx \
 --repo https://kubernetes.github.io/ingress-nginx \
 --namespace ingress-nginx \
 --create-namespace \
 -f values.yaml
```

## Usage

You can command the robot through rviz accessing the ingress Loadbalancer ip or url:

![k8s-ros2-rb-theron-rviz-web](doc/k8s-ros2-rb-theron-rviz-web.gif)

Step 1![rb-theron-rviz-01.png](doc/rb-theron-rviz-01.png)

Step 2![rb-theron-rviz-02.png](doc/rb-theron-rviz-02.png)

Step 3![rb-theron-rviz-03.png](doc/rb-theron-rviz-03.png)

Step 4![rb-theron-rviz-04.png](doc/rb-theron-rviz-04.png)

you also can access the gazebo interface using the ingress loadbalancer ip with path `gazebo`

Step 1![gazebo-01.png](doc/gazebo-01.png)

Step 2![gazebo-02.png](doc/gazebo-02.png)