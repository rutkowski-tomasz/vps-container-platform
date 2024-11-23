# 🎼 vps-container-platform

Compute on cloud is a bit overpriced for side-projects. So here is a simple terraform setup for a <ins>**docker swarm on Hetzner VPS**</ins> (4.66€/mo for 4GB + 2vCPU 👌🏻). It uses cloud-init to automate creation:
- server, with public IPv4
- access and deploy users
- firewall
- docker swarm

## 🪴 Provision

Create a Hetzner token in **Security > API Tokens** and put `hcloud_token = YOUR_TOKEN` into `terraform.tfvars` file.

```sh
terraform init
terraform apply -auto-approve
```

## 🔐 SSH into

```sh
terraform output -raw access_key | ssh-add - <<< "access@$(terraform output -raw ip)"
ssh access@$(terraform output -raw ip)
```

## 🐳 Deploy docker stack

```sh
terraform output -raw deploy_key | ssh-add - <<< "deploy@$(terraform output -raw ip)"
docker context create vps --docker "host=ssh://deploy@$(terraform output -raw ip)"
docker context use vps
docker stack deploy -c compose.yaml example
```
