## Run ansible command in ansible container (Ansible Runner)
ref: 
 - [Introduction to Ansible Runner](https://ansible-runner.readthedocs.io/en/stable/intro/)
 - [Using Runner as a container interface to Ansible](https://ansible-runner.readthedocs.io/en/stable/container/)
 - [ansible-runner/Dockerfile](https://github.com/ansible/ansible-runner/blob/devel/Dockerfile)
 - [demo](https://github.com/ansible/ansible-runner/tree/devel/demo)


## create a role
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project)
$roleName="ansible-podman-rootless-play"
podman run --rm -v ../:/runner `
    localhost/ansible-ee-aio bash -c "cd /runner/project/roles/ && ansible-galaxy init $roleName"

podman run --rm -v ../:/runner `
    localhost/ansible-ee-aio bash -c "ansible --version"
```


## deploy podman rootless
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project)

# deploy and config podman package
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-PodmanRootlessProvision.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ../:/runner `
    localhost/ansible-ee-aio `
    ansible-runner run /runner -vv

# deploy pod (run podman play)
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-PodmanRootlessPlay.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ../:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv
```

## deploy k3s
ref: 
https://github.com/PyratLabs/ansible-role-k3s/tree/main

- Add xanmanning.k3s repo as a submodule
```powershell
cd (git rev-parse --show-toplevel)
git submodule add https://github.com/PyratLabs/ansible-role-k3s.git AnsibleWorkShop/project/roles/xanmanning.k3s
# List Remote Git Tags
# https://phoenixnap.com/kb/git-list-tags
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project\roles\xanmanning.k3s)
git ls-remote --tags origin
# fetch remote tags
git fetch --all --tags --prune
# switch to the version tag
git checkout tags/v3.3.1
# if you want to remove it
cd (git rev-parse --show-toplevel)
# https://devconnected.com/how-to-clear-git-cache/#:~:text=The%20easiest%20way%20to%20clear%20your%20Git%20cache,ignore%20all%20files%20ending%20in%20%E2%80%9C%20.conf%20%E2%80%9C
git rm --cached AnsibleWorkShop/project/roles/xanmanning.k3s
```

- Ensure the ansible runner ee meet below requirement:
    - `python >= 3.6.0`
    - `ansible >= 2.9.16 or ansible-base >= 2.10.4`

- Run ansible runner to deploy k3s with role
ansible runner will make the project dir as default dir
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project)

podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-xanmanning.k3s.yml `
    -v ../:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# have a check of k3s cert
openssl s_client -connect 127.0.0.1:6443

openssl x509 -in /var/lib/rancher/k3s/server/tls/server-ca.crt -text -noout
```

## deploy k8s resource
```powershell
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml `
    -v ../:/runner `
    localhost/ansible-ee-aio

podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml `
    -v ../:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-HelmInfo.yml     
    -v ../:/runner localhost/ansible-ee-aio
    
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/test.yml `
    -v ../:/runner localhost/ansible-ee-aio `
    ansible-runner run /runner -vvvv
```

## debugs
```powershell
# terraform
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml `
    -v ../:/runner `
    -v ../../TerraformWorkShop/:/TerraformWorkShop/ `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml `
    -v ../:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# test merge
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Debug-Vars.yml `
    -v ../:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# copy item
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Copy-Items.yml `
    -v ../:/runner `
    -v ../../TerraformWorkShop/:/TerraformWorkShop/ `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# test j2 template render and copy to target
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-Podman.yml `
    -v ../:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# config podman in target host
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-KernelModules.yml `
    -v ../:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

```


## install freeipa server
```powershell
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-FreeIPA.yml `
    -v ../:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Update-Hosts.yml `
    -v ../:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Update-Hosts.yml `
    -v ../:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv
```