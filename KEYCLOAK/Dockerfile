FROM quay.io/keycloak/keycloak:26.2 AS builder

WORKDIR /opt/keycloak

COPY --chmod=0755 entrypoint.sh .

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.2

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/entrypoint.sh"]
