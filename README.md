# MyEasyRGPD_Install

## Install

### Script options

		-o, --org
			Empty by default:
				Install folder : /usr/share/MyEasyRGPD[frontend|backend]/default
				frontend url : orgname.mydpia.eu
				backend url : back.orgname.mydpia.eu
			Not empty:
				Install folder : /usr/share/MyEasyRGPD[frontend|backend]/orgname
				frontend url : front.mydpia.eu
				backend url : back.mydpia.eu

		-a, --application
			No default value - Mandatory option
				- front
				- back

		-e, --encrypt-mail
			No default value - Mandatory option

		-i, --client-id (Frontend only)
			No default value - Mandatory option (frontend)

		-s, --client-secret (Frontend only)
			No default value - Mandatory option (frontend)

		-u, --backend-url (Frontend only)
			Default value : back.mydpia.eu

### Install app workflow 

#### 1) Install Backend 

Script options: 

	[Mandatory]
	-a back

	-e <MAIL> 
		Needed for Keys alert & warning

	[Optional]
	-o <ORGNAME>
		If empty - Create default APP
			install folder: /usr/share/MyEasyRGPD/backend/default
			url: back.mydpia.eu
		If Not empty:
			install folder : /usr/share/MyEasyRGPD/backend/orgname
			url : back.<ORGNAME>.mydpia.eu

Execute install command: 

```bash
bash install.sh -a back -e <MAIL> [-o <ORGNAME>]
```

#### 2) Setup frontend app in backend (Before install frontend)

- Go to Application menu: 

![alt text](_DOC/app0.png)

- Create New Application:

![alt text](_DOC/app1.png)

- Get the generated client credentials (ID & Secret):

![alt text](_DOC/app2.png)

#### 3) Install frontend

Script options:

	[Mandatory] 
	-a front

	-e <MAIL> 
		Needed for Keys alert & warning

	-i <CLIENT_ID>
		(Credentials set in the previous step)

	-s <CLIENT_SECRET>
		(Credentials set in the previous step)

	[Optional]
	-o <ORGNAME>
		If empty - Create default APP
			install folder: /usr/share/MyEasyRGPD/frontend/default
			url: front.mydpia.eu
		If Not empty:
			install folder : /usr/share/MyEasyRGPD/frontend/orgname
			url : <ORGNAME>.mydpia.eu

	-u <BACKEND_URL> - (Format : http://BACKEND_URL)
		If empty - Use default backend
			url: http://back.mydpia.eu

Execute install command: 

```bash
bash install.sh -a front -e <MAIL> -i <CLIENT_ID> -s <CLIENT_SECRET> [-u <BACKEND_URL> -o <ORGNAME>]
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
