# MyEasyRGPD_Install

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

This will install the "org1" frontend: 

```bash
bash install.sh  -o org1 -a front -e test@mail.com --client-id 1234 --client-secret 987654321
```

## Uninstall

### Script options

		-o, --org
			No default value - Mandatory option

		-a, --application
			No default value - Mandatory option
			- frontend, front
			- backend, back

### Example

```bash
bash uninstall.sh -o <ORGNAME> -a <APP>
```

This will remove the default backend app : 

```bash
bash uninstall.sh -o default -a Back
```
