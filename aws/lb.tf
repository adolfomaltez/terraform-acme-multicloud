# Create an application load balancer security group.
resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.acme-vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags {
  #  Name = "terraform-example-alb-security-group"
  #}
}

# Create a new application load balancer.
resource "aws_alb" "alb" {
  name            = "acme-app-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = [ aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id ] 

  #tags {
  #  Name = "terraform-example-alb"
  #}
}

# Create a new target group for the application load balancer.
resource "aws_alb_target_group" "group" {
  name     = "acme-app-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.acme-vpc.id

  stickiness {
    type = "lb_cookie"
  }

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/index.html"
    port = 80
  }
}

resource "aws_lb_target_group_attachment" "webserver-a" {
  target_group_arn = aws_alb_target_group.group.arn
  target_id        = aws_instance.webserver-a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webserver-b" {
  target_group_arn = aws_alb_target_group.group.arn
  target_id        = aws_instance.webserver-b.id
  port             = 80
}

# Create a new application load balancer listener for HTTP.
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}

output "alb_dns_name" {
value = aws_alb.alb.dns_name
}
