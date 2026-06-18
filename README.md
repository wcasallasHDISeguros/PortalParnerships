# PortalParnerships
# Pipeline de Replicación CDC: Oracle a Amazon Redshift (Serverless)

Este repositorio contiene la arquitectura, el código de infraestructura y los scripts de procesamiento para el pipeline de ingesta de datos en tiempo real y consolidación analítica desde una base de datos **Oracle (On-Premise)** hacia **Amazon Redshift (AWS Cloud)** utilizando un enfoque *Event-Driven* y arquitectura de capas (Staging / Silver).

## 🏗️ Arquitectura General

El flujo de datos está diseñado bajo el principio de desacoplamiento absoluto mediante el uso de almacenamiento intermedio (Amazon S3) y una capa de control NoSQL (Amazon DynamoDB).
