# MyEasyRGPD_Install

## 1) Set .env file

```.env
VIRTUAL_HOST=<VIRTUAL_HOST>
LETSENCRYPT_HOST=<LETSENCRYPT_HOST>
LETSENCRYPT_EMAIL=<LETSENCRYPT_EMAIL>
```

## 2) 

  -i, --client-id

  -s, --client-secret

  -u, --backend-url

## Install

### Script options

		-o, --org
			Empty by default:
				Install folder : /usr/share/MyEasyRGPD[frontend|backend]/default
				frontend url : orgname.myeasyrgpd.lusis.lu
				backend url : back.orgname.myeasyrgpd.lusis.lu
			Not empty:
				Install folder : /usr/share/MyEasyRGPD[frontend|backend]/orgname
				frontend url : front.myeasyrgpd.lusis.lu
				backend url : back.myeasyrgpd.lusis.lu

		-a, --application
			No default value - Mandatory option
				- frontend, front
				- backend, back

		-e, --encrypt-mail
			No default value - Mandatory option

		-i, --client-id (Frontend only)
			No default value - Mandatory option (frontend)

		-s, --client-secret (Frontend only)
			No default value - Mandatory option (frontend)

		-u, --backend-url (Frontend only)
			Default value : back.myeasyrgpd.lusis.lu

### Example

```bash
bash install.sh -o <ORGNAME> -a <APP> -e <MAIL>
```

```bash
bash install.sh  -o <ORGNAME> -a <APP> -e <MAIL> --client-id <ID> --client-secret <SECRET>
```

## Uninstall

### Script options

		-o, --org
			No default value - Mandatory option

		-a, --application
			No default value - Mandatory option
			- frontend, front
			- backend, back

		-v, --volume
			Remove docker volumes (Only for current App)
			Default value : Keep volumes - Optional

		-i, --image
			Remove docker images (Only for current App)
			Default value : Keep images - Optional

### Example

```bash
bash uninstall.sh -o <ORGNAME> -a <APP> --image --volume
```

```bash
bash uninstall.sh -o <ORGNAME> -a <APP> -i -v
```
