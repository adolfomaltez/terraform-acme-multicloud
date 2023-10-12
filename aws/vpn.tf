resource "aws_acm_certificate" "server_vpn_cert" {
  certificate_body  = file("/home/taro/my-vpn-files/server.crt")
  private_key       = file("/home/taro/my-vpn-files/server.key")
  certificate_chain = file("/home/taro/my-vpn-files/ca.crt")
}

resource "aws_acm_certificate" "client_vpn_cert" {
  certificate_body  = file("/home/taro/my-vpn-files/client1.domain.tld.crt")
  private_key       = file("/home/taro/my-vpn-files/client1.domain.tld.key")
  certificate_chain = file("/home/taro/my-vpn-files/ca.crt")
}

resource "aws_ec2_client_vpn_endpoint" "my_client_vpn" {
  description            = "My client vpn"
  server_certificate_arn = aws_acm_certificate.server_vpn_cert.arn
  client_cidr_block      = "10.10.0.0/22"
  vpc_id                 = aws_vpc.acme-vpc.id
  
  security_group_ids     = [aws_security_group.vpn_secgroup.id]
  split_tunnel           = true

  # Client authentication
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_vpn_cert.arn
  }

  connection_log_options {
    enabled = false
   }

  depends_on = [
    aws_acm_certificate.server_vpn_cert,
    aws_acm_certificate.client_vpn_cert
  ]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_public_a" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = aws_subnet.public_subnet_a.id
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_public_b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = aws_subnet.public_subnet_b.id
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  
  target_network_cidr    = "10.0.0.0/16"
  authorize_all_groups   = true
}


## Export the ovpn configuration file
#aws ec2 export-client-vpn-client-configuration \
#    --client-vpn-endpoint-id cvpn-endpoint-123456789123abcde \
#    --output text

## Command to connect to VPN
# openvpn --config /home/taro/Downloads/downloaded-client-config.ovpn --cert ../my-vpn-files/client1.domain.tld.crt --key ../my-vpn-files/client1.domain.tld.key 

## Save VPN file
#resource "local_file" "vpn_config" {
#  filename = "acme_client_vpn.ovpn"
#  content  = awsutils_ec2_client_vpn_export_client_config.my_client_vpn.id
#  file_permission = 0400
#}