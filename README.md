# MyEasyRGPD_Install

## 1) SET .ENV FILE

```.env
VIRTUAL_HOST=<VIRTUAL_HOST>
LETSENCRYPT_HOST=<LETSENCRYPT_HOST>
LETSENCRYPT_EMAIL=<LETSENCRYPT_EMAIL>
```

## 2) EXECUTE SCRIPT

- SYSTEM    : ubuntu centos archlinux
- APP       : backend frontend

### INSTALL

```bash
bash install.sh -s <SYSTEM> -a <APP>
```

### UNINSTALL

```bash
bash uninstall.sh -s <SYSTEM> -a <APP>
```
