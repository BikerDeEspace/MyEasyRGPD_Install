# MyEasyRGPD_Install

## 1) Set .env file

```.env
VIRTUAL_HOST=<VIRTUAL_HOST>
LETSENCRYPT_HOST=<LETSENCRYPT_HOST>
LETSENCRYPT_EMAIL=<LETSENCRYPT_EMAIL>
```

## 2) Execute script

- SYSTEM    : ubuntu centos archlinux
- APP       : backend frontend

### Install

```bash
bash install.sh -s <SYSTEM> -a <APP>
```

### Uninstall

```bash
bash uninstall.sh -s <SYSTEM> -a <APP>
```
