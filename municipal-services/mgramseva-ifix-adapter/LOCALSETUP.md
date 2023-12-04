# Local Setup

To setup the mgramseva-ifix-adapter in your local system, clone the [Muncipal Service repository](https://github.com/egovernments/punjab-mgramseva).

## Dependencies

### Infra Dependency
- [x] Kafka
  - [x] Consumer
 

## Running Locally

To run the mgramseva-ifix-adapter in local system, you need to port forward below services.

```bash
 function kgpt(){kubectl get pods -n egov --selector=app=$1 --no-headers=true | head -n1 | awk '{print $1}'}
 kubectl port-forward -n egov $(kgpt ifix-reference-adapter) 8086:8080 &
 kubectl port-forward -n egov $(kgpt egov-mdms-service) 8085:8080 &
``` 

Update below listed properties in `application.properties` before running the project:

```ini

egov.mdms.host = http://localhost:8085/
egov.ifix.refernce.adapter.host = http://localhost:8086/
```