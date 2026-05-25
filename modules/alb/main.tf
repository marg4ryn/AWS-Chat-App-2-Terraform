resource "aws_lb" "main" {
  name            = "${var.app_name}-alb"
  subnets         = var.public_subnet_ids
  security_groups = [var.alb_sg_id]
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "options" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chat.arn
  }

  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }
}

resource "aws_lb_target_group" "chat" {
  name        = "${var.app_name}-chat-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/actuator/health" }
}

resource "aws_lb_target_group" "media" {
  name        = "${var.app_name}-media-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/actuator/health" }
}

resource "aws_lb_target_group" "notifications" {
  name        = "${var.app_name}-notifications-tg"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/actuator/health" }
}

resource "aws_lb_target_group" "auth" {
  name        = "${var.app_name}-auth-tg"
  port        = 8083
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/actuator/health" }
}

resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }
  condition {
    path_pattern { values = ["/api/auth", "/api/auth/*"] }
  }
}

resource "aws_lb_listener_rule" "chat" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chat.arn
  }
  condition {
    path_pattern { values = ["/api/rooms", "/api/rooms/*"] }
  }
}

resource "aws_lb_listener_rule" "media" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 30
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.media.arn
  }
  condition {
    path_pattern { values = ["/api/media", "/api/media/*"] }
  }
}

resource "aws_lb_listener_rule" "notifications" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 40
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notifications.arn
  }
  condition {
    path_pattern { values = ["/api/notifications", "/api/notifications/*"] }
  }
}
