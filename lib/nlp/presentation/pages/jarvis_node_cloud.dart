import 'dart:math';
import 'package:flutter/material.dart';

enum NodeAnimationType {
  cloud,
  expansionWave,
  sphere,
  flowField,
  // Puedes agregar más animaciones aquí
}

class JarvisNodeCloud extends StatefulWidget {
  final double speed;
  final double tics;
  final int nodeCount;
  final double colorRatio;
  final NodeAnimationType animationType;

  // Parámetros para ExpansionWaveNodeAnimator
  final double maxRadius;
  final int numRipples;
  final double period;

  // Parámetros para SphereNodeAnimator y FlowFieldNodeAnimator
  final double radius;

  const JarvisNodeCloud({
    Key? key,
    this.speed = 2,
    this.tics = 1,
    this.nodeCount = 300,
    this.colorRatio = 0.0,
    this.animationType = NodeAnimationType.expansionWave,
    this.maxRadius = 100.0,
    this.numRipples = 5,
    this.period = 100.0,
    this.radius = 200.0,
  }) : super(key: key);

  @override
  _JarvisNodeCloudState createState() => _JarvisNodeCloudState();
}

class _JarvisNodeCloudState extends State<JarvisNodeCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Node> nodes = [];
  late NodeAnimator nodeAnimator;

  bool transitioning = false;
  double transitionDuration = 0.5; // Duración de la transición en segundos

  double lastUpdateTime = 0.0;

  @override
  void initState() {
    super.initState();
    assignAnimator();

    // Inicializar nodos después de que el contexto esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeNodes();
      startAnimation();
    });
  }

  void assignAnimator() {
    switch (widget.animationType) {
      case NodeAnimationType.cloud:
        nodeAnimator = CloudNodeAnimator(
          speed: widget.speed,
          tics: widget.tics,
          colorRatio: widget.colorRatio,
          nodeCount: widget.nodeCount,
          radius: widget.radius,
          transitionDuration: transitionDuration,
        );
        break;
      case NodeAnimationType.expansionWave:
        nodeAnimator = ExpansionWaveNodeAnimator(
          speed: widget.speed,
          nodeCount: widget.nodeCount,
          maxRadius: widget.maxRadius,
          numRipples: widget.numRipples,
          period: widget.period,
          transitionDuration: transitionDuration,
        );
        break;
      case NodeAnimationType.sphere:
        nodeAnimator = SphereNodeAnimator(
          speed: widget.speed,
          nodeCount: widget.nodeCount,
          radius: widget.radius,
          transitionDuration: transitionDuration,
        );
        break;
      case NodeAnimationType.flowField:
        nodeAnimator = FlowFieldNodeAnimator(
          speed: widget.speed,
          nodeCount: widget.nodeCount,
          radius: widget.radius,
          transitionDuration: transitionDuration,
        );
        break;
    }
  }

  @override
  void didUpdateWidget(covariant JarvisNodeCloud oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animationType != oldWidget.animationType) {
      assignAnimator();
      startTransition();
    }
    nodeAnimator.updateParameters(widget);
    if (widget.nodeCount != oldWidget.nodeCount) {
      adjustNodeCount(widget.nodeCount);
      nodeAnimator.initializeNodes(nodes, MediaQuery.of(context).size,
          forTransition: false);
    }
  }

  void startTransition() {
    setState(() {
      transitioning = true;
      // Para cada nodo, establece la posición inicial y calcula la posición objetivo
      final size = MediaQuery.of(context).size;
      nodeAnimator.initializeNodes(nodes, size, forTransition: true);
    });
  }

  void adjustNodeCount(int newCount) {
    if (nodes.length < newCount) {
      // Agregar nuevos nodos
      int nodesToAdd = newCount - nodes.length;
      for (int i = 0; i < nodesToAdd; i++) {
        nodes.add(Node(
          position: Offset.zero,
          size: 1.0,
          depth: 0.0,
          color: Colors.cyanAccent,
        ));
      }
    } else if (nodes.length > newCount) {
      // Eliminar nodos sobrantes
      nodes.removeRange(newCount, nodes.length);
    }
  }

  void initializeNodes() {
    final size = MediaQuery.of(context).size;
    if (nodes.isEmpty) {
      // Inicializar nodos por primera vez
      for (int i = 0; i < widget.nodeCount; i++) {
        nodes.add(Node(
          position: Offset.zero,
          size: 1.0,
          depth: 0.0,
          color: Colors.cyanAccent,
        ));
      }
    }
    nodeAnimator.initializeNodes(nodes, size, forTransition: false);
  }

  void startAnimation() {
    _controller = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      final currentTime =
          _controller.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0.0;
      double deltaTime = (currentTime - lastUpdateTime) / 1000.0;
      lastUpdateTime = currentTime;

      updateNodesWithDelta(deltaTime);
    });
  }

  void updateNodesWithDelta(double deltaTime) {
    setState(() {
      final size = MediaQuery.of(context).size;
      nodeAnimator.updateNodes(nodes, size, deltaTime);

      if (transitioning) {
        bool allNodesTransitioned =
            nodes.every((node) => node.transitionProgress >= 1.0);
        if (allNodesTransitioned) {
          transitioning = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NodeCloudPainter(nodes: nodes),
      child: Container(),
    );
  }
}

abstract class NodeAnimator {
  final double transitionDuration;

  NodeAnimator({required this.transitionDuration});

  void initializeNodes(List<Node> nodes, Size size,
      {bool forTransition = false});
  void updateNodes(List<Node> nodes, Size size, double deltaTime);
  void updateParameters(JarvisNodeCloud widget);
}

class FlowFieldNodeAnimator extends NodeAnimator {
  double speed;
  int nodeCount;
  double radius;
  double time = 0.0;

  FlowFieldNodeAnimator({
    required this.speed,
    required this.nodeCount,
    required this.radius,
    required double transitionDuration,
  }) : super(transitionDuration: transitionDuration);

  @override
  void initializeNodes(List<Node> nodes, Size size,
      {bool forTransition = false}) {
    final random = Random();
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (var node in nodes) {
      if (forTransition) {
        node.startPosition = node.position;
      } else {
        node.startPosition = center;
      }

      // Generar una posición aleatoria dentro de la esfera
      double theta = random.nextDouble() * 2 * pi;
      double phi = acos(2 * random.nextDouble() - 1);
      double r = random.nextDouble() * radius;

      double x = r * sin(phi) * cos(theta);
      double y = r * sin(phi) * sin(theta);
      double z = r * cos(phi);

      node.position3D = Vector3(x, y, z);
      node.velocity3D = Vector3(0.0, 0.0, 0.0);

      node.transitionProgress = 0.0;

      // Profundidad para efectos visuales
      double depth = (z + radius) / (2 * radius);
      node.depth = depth;
      node.size = (1 - depth) * 2 + 1;

      // Establecer posición 2D inicial
      double screenX = center.dx + x;
      double screenY = center.dy - y;
      node.targetPosition = Offset(screenX, screenY);

      // Color inicial
      node.color = Colors.cyanAccent;
    }
  }

  @override
  void updateNodes(List<Node> nodes, Size size, double deltaTime) {
    time += deltaTime;

    final Offset center = Offset(size.width / 2, size.height / 2);

    for (var node in nodes) {
      if (node.transitionProgress < 1.0) {
        node.transitionProgress += deltaTime / transitionDuration;
        if (node.transitionProgress > 1.0) node.transitionProgress = 1.0;
        node.position = Offset.lerp(
            node.startPosition, node.targetPosition, node.transitionProgress)!;
      } else {
        // Actualizar la velocidad basada en el campo de flujo
        Vector3 flow = calculateFlowField(node.position3D, time);
        node.velocity3D = node.velocity3D + flow * deltaTime;

        // Limitar la velocidad a un máximo
        double maxSpeed = speed;
        double velocityLength = node.velocity3D.length;
        if (velocityLength > maxSpeed) {
          node.velocity3D = node.velocity3D * (maxSpeed / velocityLength);
        }

        // Actualizar posición
        node.position3D = node.position3D + node.velocity3D * deltaTime;

        // Mantener el nodo dentro de la esfera
        double distanceFromCenter = node.position3D.length;
        if (distanceFromCenter > radius) {
          // Reflejar la posición hacia el interior de la esfera
          node.position3D = node.position3D * (radius / distanceFromCenter);
          // Reflejar la velocidad
          Vector3 normal = node.position3D.normalized();
          double dotProduct = node.velocity3D.x * normal.x +
              node.velocity3D.y * normal.y +
              node.velocity3D.z * normal.z;
          node.velocity3D = node.velocity3D - normal * (2 * dotProduct);
        }

        // Profundidad para efectos visuales
        double depth = (node.position3D.z + radius) / (2 * radius);
        node.depth = depth;
        node.size = (1 - depth) * 2 + 1;

        // Proyectar posición 3D a 2D
        double screenX = center.dx + node.position3D.x;
        double screenY = center.dy - node.position3D.y;
        node.position = Offset(screenX, screenY);

        // Cambiar el color basado en la velocidad
        double speedRatio = node.velocity3D.length / speed;
        node.color =
            Color.lerp(Colors.blue, Colors.red, speedRatio.clamp(0.0, 1.0))!;
      }
    }
  }

  Vector3 calculateFlowField(Vector3 position, double time) {
    // Función simple de campo de flujo
    double flowX = sin(position.y * 0.05 + time);
    double flowY = sin(position.z * 0.05 + time);
    double flowZ = sin(position.x * 0.05 + time);

    return Vector3(flowX, flowY, flowZ);
  }

  @override
  void updateParameters(JarvisNodeCloud widget) {
    speed = widget.speed;
    radius = widget.radius;

    if (nodeCount != widget.nodeCount) {
      nodeCount = widget.nodeCount;
    }
  }
}

class CloudNodeAnimator extends NodeAnimator {
  double speed;
  double tics;
  double colorRatio;
  int nodeCount;
  double radius;

  CloudNodeAnimator({
    required this.speed,
    required this.tics,
    required this.colorRatio,
    required this.nodeCount,
    required super.transitionDuration,
    required this.radius,
  });

  @override
  void initializeNodes(List<Node> nodes, Size size,
      {bool forTransition = false}) {
    final random = Random();
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (var node in nodes) {
      if (forTransition) {
        node.startPosition = node.position;
      } else {
        node.startPosition = center;
      }

      // Generar una posición aleatoria dentro del orbe
      double rradius = random.nextDouble() * radius;
      double theta = random.nextDouble() * 2 * pi;
      double phi = acos(2 * random.nextDouble() - 1);

      double x = rradius * sin(phi) * cos(theta);
      double y = rradius * sin(phi) * sin(theta);

      node.targetPosition = Offset(center.dx + x, center.dy + y);
      node.transitionProgress = 0.0;

      // Profundidad (para efectos visuales)
      double depth = rradius / radius;

      // Tamaño ajustado por profundidad
      node.size = (1 - depth) * 2 + 1;
      node.depth = depth;

      // Velocidad inicial aleatoria
      double vx = (random.nextDouble() - 0.5) * speed;
      double vy = (random.nextDouble() - 0.5) * speed;
      node.velocity = Offset(vx, vy);

      // Color inicial
      node.color = Colors.cyanAccent;
    }
  }

  @override
  void updateNodes(List<Node> nodes, Size size, double deltaTime) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (var node in nodes) {
      if (node.transitionProgress < 1.0) {
        node.transitionProgress += deltaTime / transitionDuration;
        if (node.transitionProgress > 1.0) node.transitionProgress = 1.0;
        node.position = Offset.lerp(
            node.startPosition, node.targetPosition, node.transitionProgress)!;
      } else {
        // Actualizar la posición del nodo
        node.position += node.velocity * deltaTime;

        // Calcular la distancia desde el centro
        double dx = node.position.dx - center.dx;
        double dy = node.position.dy - center.dy;
        double distanceFromCenter = sqrt(dx * dx + dy * dy);

        // Si el nodo supera el radio máximo, rebotar
        if (distanceFromCenter >= radius) {
          // Normalizar la dirección
          double nx = dx / distanceFromCenter;
          double ny = dy / distanceFromCenter;

          // Reflejar la velocidad
          double dotProduct = node.velocity.dx * nx + node.velocity.dy * ny;
          node.velocity =
              node.velocity - Offset(2 * dotProduct * nx, 2 * dotProduct * ny);

          // Ajustar la posición para que esté dentro del orbe
          double overlap = distanceFromCenter - radius;
          node.position -= Offset(nx * overlap, ny * overlap);
        }

        // Opcional: Cambiar la velocidad aleatoriamente
        if (Random().nextDouble() < tics * deltaTime) {
          node.velocity = Offset(
            (Random().nextDouble() - 0.5) * speed,
            (Random().nextDouble() - 0.5) * speed,
          );
        }

        // Opcional: Cambiar el color aleatoriamente
        if (Random().nextDouble() < colorRatio * deltaTime) {
          node.color = Color.fromRGBO(
            Random().nextInt(255),
            Random().nextInt(255),
            Random().nextInt(255),
            1,
          );
        }
      }
    }
  }

  @override
  void updateParameters(JarvisNodeCloud widget) {
    speed = widget.speed;
    tics = widget.tics;
    colorRatio = widget.colorRatio;
    radius = widget.radius;

    if (nodeCount != widget.nodeCount) {
      nodeCount = widget.nodeCount;
    }
  }
}

class ExpansionWaveNodeAnimator extends NodeAnimator {
  double speed;
  int nodeCount;
  double maxRadius;
  int numRipples;
  double period;
  double time = 0.0; // Lleva el tiempo de la animación

  ExpansionWaveNodeAnimator({
    required this.speed,
    required this.nodeCount,
    required this.maxRadius,
    required this.numRipples,
    required this.period,
    required double transitionDuration,
  }) : super(transitionDuration: transitionDuration);

  @override
  void initializeNodes(List<Node> nodes, Size size,
      {bool forTransition = false}) {
    final random = Random();
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < nodes.length; i++) {
      var node = nodes[i];

      if (forTransition) {
        node.startPosition = node.position;
      } else {
        node.startPosition = center;
      }

      node.depth = 0.0;
      // Asignar un ángulo aleatorio entre 0 y 2π
      node.angle = random.nextDouble() * 2 * pi;

      // Calcular la fase basada en el índice de la onda
      int rippleIndex = i % numRipples;
      node.phase = (2 * pi / numRipples) * rippleIndex;

      double sizeNode = random.nextDouble() * 2 + 1;
      node.size = sizeNode;
      node.transitionProgress = 0.0;
    }
  }

  @override
  void updateNodes(List<Node> nodes, Size size, double deltaTime) {
    time += deltaTime * speed;

    final Offset center = Offset(size.width / 2, size.height / 2);

    for (var node in nodes) {
      // Calcular el radio actual
      double radius =
          maxRadius * 0.5 * (1 + sin((2 * pi / period) * time + node.phase));

      // Calcular la posición objetivo
      node.targetPosition = Offset(
        center.dx + radius * cos(node.angle),
        center.dy + radius * sin(node.angle),
      );

      if (node.transitionProgress < 1.0) {
        node.transitionProgress += deltaTime / transitionDuration;
        if (node.transitionProgress > 1.0) node.transitionProgress = 1.0;
        node.position = Offset.lerp(
            node.startPosition, node.targetPosition, node.transitionProgress)!;
      } else {
        node.position = node.targetPosition;
      }
    }
  }

  @override
  void updateParameters(JarvisNodeCloud widget) {
    speed = widget.speed;
    maxRadius = widget.maxRadius;
    numRipples = widget.numRipples;
    period = widget.period;

    if (nodeCount != widget.nodeCount) {
      nodeCount = widget.nodeCount;
    }
  }
}

class SphereNodeAnimator extends NodeAnimator {
  double speed;
  int nodeCount;
  double radius;

  SphereNodeAnimator({
    required this.speed,
    required this.nodeCount,
    required this.radius,
    required double transitionDuration,
  }) : super(transitionDuration: transitionDuration);

  @override
  void initializeNodes(List<Node> nodes, Size size,
      {bool forTransition = false}) {
    final random = Random();

    for (var node in nodes) {
      if (forTransition) {
        node.startPosition = node.position;
      } else {
        node.startPosition = Offset(size.width / 2, size.height / 2);
      }

      // Generar ángulos aleatorios theta (0 a 2π) y phi (0 a π)
      node.theta = random.nextDouble() * 2 * pi;
      node.phi = acos(2 * random.nextDouble() - 1);

      node.transitionProgress = 0.0;
    }
  }

  @override
  void updateNodes(List<Node> nodes, Size size, double deltaTime) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (var node in nodes) {
      // Actualizar theta y phi para mover el nodo sobre la superficie de la esfera
      node.theta += speed * deltaTime * 0.5;
      node.phi += speed * deltaTime * 0.3;

      // Mantener los ángulos dentro de los rangos válidos
      node.theta %= 2 * pi;
      node.phi %= pi;

      // Convertir coordenadas esféricas a cartesianas
      double x = radius * sin(node.phi) * cos(node.theta);
      double y = radius * sin(node.phi) * sin(node.theta);
      double z = radius * cos(node.phi);

      // Proyección perspectiva simple
      double scale =
          (z + radius) / (2 * radius); // Escala basada en la profundidad

      // Mapear a posición 2D en el lienzo
      double screenX = center.dx + x;
      double screenY = center.dy - y; // Invertir eje y si es necesario

      // Establecer posición objetivo
      node.targetPosition = Offset(screenX, screenY);

      if (node.transitionProgress < 1.0) {
        node.transitionProgress += deltaTime / transitionDuration;
        if (node.transitionProgress > 1.0) node.transitionProgress = 1.0;
        node.position = Offset.lerp(
            node.startPosition, node.targetPosition, node.transitionProgress)!;
      } else {
        // Después de la transición, establecer posición a la posición objetivo
        node.position = node.targetPosition;
      }

      // Actualizar tamaño u opacidad basada en la profundidad (z)
      node.size = (1 + scale) * 2; // Ajustar tamaño basado en la escala
      node.depth = scale; // Usar profundidad para opacidad u otros efectos
    }
  }

  @override
  void updateParameters(JarvisNodeCloud widget) {
    speed = widget.speed;
    radius = widget.radius;

    if (nodeCount != widget.nodeCount) {
      nodeCount = widget.nodeCount;
    }
  }
}

class Node {
  Offset position; // Posición actual
  Offset startPosition; // Posición inicial para la transición
  Offset targetPosition; // Posición objetivo para la transición
  Offset velocity; // Para movimientos en 2D
  Vector3 position3D; // Posición 3D
  Vector3 velocity3D; // Velocidad 3D
  double angle;
  double angularSpeed;
  double phase;
  double size;
  double depth;
  Color color;
  double theta;
  double phi;
  double transitionProgress; // 0.0 a 1.0

  Node({
    required this.position,
    required this.size,
    required this.depth,
    required this.color,
    this.velocity = Offset.zero,
    this.position3D = const Vector3(0.0, 0.0, 0.0),
    this.velocity3D = const Vector3(0.0, 0.0, 0.0),
    this.angle = 0.0,
    this.angularSpeed = 0.0,
    this.phase = 0.0,
    this.phi = 0.0,
    this.theta = 0.0,
    Offset? startPosition,
    Offset? targetPosition,
    this.transitionProgress = 1.0, // Por defecto, sin transición
  })  : startPosition = startPosition ?? position,
        targetPosition = targetPosition ?? position;
}

class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) =>
      Vector3(x + other.x, y + other.y, z + other.z);

  Vector3 operator -(Vector3 other) =>
      Vector3(x - other.x, y - other.y, z - other.z);

  Vector3 operator *(double scalar) =>
      Vector3(x * scalar, y * scalar, z * scalar);

  double get length => sqrt(x * x + y * y + z * z);

  Vector3 normalized() {
    double l = length;
    if (l == 0) return Vector3(0, 0, 0);
    return Vector3(x / l, y / l, z / l);
  }
}

class NodeCloudPainter extends CustomPainter {
  final List<Node> nodes;

  NodeCloudPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint nodePaint = Paint()..style = PaintingStyle.fill;
    final Paint linePaint = Paint()..strokeWidth = 1;

    // Dibujar nodos
    for (var node in nodes) {
      double opacity = 0.3 + 0.7 * node.depth;
      nodePaint.color = node.color.withOpacity(opacity);
      canvas.drawCircle(node.position, node.size, nodePaint);
    }

    // Dibujar líneas entre nodos cercanos (solo para la animación de nube)
    if (nodes.isNotEmpty && nodes.first.depth != 0.0) {
      for (int i = 0; i < nodes.length; i++) {
        for (int j = i + 1; j < nodes.length; j++) {
          double distance = (nodes[i].position - nodes[j].position).distance;
          double depthDifference = (nodes[i].depth - nodes[j].depth).abs();

          if (distance < 80 && depthDifference < 0.2) {
            double opacity =
                (1 - (distance / 80)) * 0.5 * (1 - depthDifference);
            linePaint.color = nodes[i].color.withOpacity(opacity);
            canvas.drawLine(nodes[i].position, nodes[j].position, linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(NodeCloudPainter oldDelegate) => true;
}
