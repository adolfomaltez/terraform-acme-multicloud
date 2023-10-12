# Implementacion de infraestructura ACME
Definicion de Infraestructura como codigo para empresa ACME, en proveedores de nube AWS y Azure.

# AWS
![acme aws diagram](aws/acme-aws.png)


### Implementacion de infraestructura en AWS:
- [ ] Clonar repositorio git:
```sh
git clone https://github.com/adolfomaltez/terraform-acme-multicloud
```
- [ ] Instalar awscli
- [ ] Configurar credenciales de AWS en /home/usuario/.aws/credentials
- [ ] Ejecutar codigo terraform
```sh
cd terraform-acme-multicloud
cd aws
terraform init
terraform plan
terraform apply -auto-approve
```
- [ ] Es necesario esperar de 10 a 15 minutos para el aprovisionamiento de la infraestructura.
- [ ] Validar acceso a aplicacion WEB (a traves del balanceador)
- [ ] Validar acceso SSH a servidores via VPN.
  - [ ] Descargar fichero de configuracion cliente VPN
  - [ ] Conectarse a VPN
  - [ ] Connectarse via SSH a los servidores.
- [ ] Destruir infraestructura para que no genere costos adicionales.
```sh
terraform destroy -auto-approve
```

# Azure

## References
- [Install the Azure CLI on Linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)