# mgramseva-ifix-adapter
This module created as wrapper for pushing demand,bill and payment events to IFIX.
### DB UML Diagram

- NA

### Service Dependencies
- egov-mdms service
- ifix-reference-adapter


### Swagger API Contract

- NA

## Service Details

**Functionality:**
- This service will listen the demand,bill and payment events and call the reference adapter push api to publish events to IFIX.


### API Details

- NA

### Kafka Consumers

- Following are the Consumer topic.
    - **mgramseva-create-demand**, **mgramseva-update-demand**, **mgramseva-create-bill**,**mgramseva-update-bill** and **egov.collection.payment-create** this topics are used to push data to IFIX.
### Kafka Producers
- NA