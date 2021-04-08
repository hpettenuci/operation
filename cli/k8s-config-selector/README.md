# Kubernets Config Selector

When you have a lot of Kubernets clusters, manage configs files is a hard task. This tool will help you change between these files easier.

# Requirements

To execute que k8s-config-selector, please install Python libraries using the following command:

```bash
pip3 install --user -r ./requirements.txt
```

# Running

To make easier to run, it's recommended create a symbolic to /usr/local/bin. After that, you just need type the command without parameters.

```bash
sudo ln -sf ./k8s-config-selector /usr/local/bin/k8s-config-selector
k8s-config-selector
```