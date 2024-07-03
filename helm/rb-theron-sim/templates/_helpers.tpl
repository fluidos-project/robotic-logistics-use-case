---
{{- define "ros-probes" }}
          startupProbe:
            exec:
              command:
                - ros_entrypoint.sh
                - ros_healthcheck.sh
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          readinessProbe:
            exec:
              command:
                - ros_entrypoint.sh
                - ros_healthcheck.sh
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30
            timeoutSeconds: 10
          livenessProbe:
            exec:
              command:
                - ros_entrypoint.sh
                - ros_healthcheck.sh
            initialDelaySeconds: 60
            periodSeconds: 20
            failureThreshold: 30
            timeoutSeconds: 10
{{- end }}

{{- define "zenoh-session-volumes" }}
{{- if eq .Values.ros.rmw "rmw_zenoh_cpp"}}
        - name: zenoh-cfg
          configMap:
            name: {{ .Release.Name }}-{{ .Release.Revision }}-zenoh-config
            items:
              - key: zenoh-sessions.config.json5
                path: zenoh-sessions.config.json5
{{- end}}
{{- end}}

{{- define "zenoh-session-volume-mount" }}
{{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
            - name: zenoh-cfg
              mountPath: /home/robot/config/zenoh-sessions.config.json5
              subPath: zenoh-sessions.config.json5
{{- end}}
{{- end}}

{{- define "simulation-image" }}
{{- if eq .Values.ros.images.registry "docker.io" }}
          image: {{ .Values.ros.images.project }}/{{ .Values.ros.images.image }}:{{ .Values.ros.images.simulation }}-{{ .Values.ros.distro }}-{{ .Values.ros.images.version }}
{{- else}}
          image: {{ .Values.ros.images.registry }}/{{ .Values.ros.images.project }}/{{ .Values.ros.images.image }}:{{ .Values.ros.images.simulation }}-{{ .Values.ros.distro }}-{{ .Values.ros.images.version }}
{{- end}}
          imagePullPolicy: Always
{{- end}}
{{- define "ros-common-env" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-ros-env
{{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-zenoh-session-env
{{- end}}
{{- end}}

{{- define "robot-1-env" }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-robot-1-id-env
{{- end}}


{{- define "lifecycle" }}

{{- if eq .Values.containers.environment.production true }}
          lifecycle:
            postStart:
              exec:
                command:
                  - "/bin/bash"
                  - "-c"
                  - |
                    sudo chmod -x \
                      /usr/bin/aria2c \
                      /usr/bin/wget \
                      /usr/bin/curl \
                      /usr/bin/curl-config \
                      /usr/bin/sftp
                    if [[ -e /etc/sudoers.d/robot ]]; then
                      sudo rm /etc/sudoers.d/robot || exit 1
                    else
                      sudo sed -i '/%robot ALL=(ALL) NOPASSWD:ALL/d' /etc/sudoers || exit 1
                    fi
                    exit 0
{{- end}}
{{- end}}

{{- define "robot-1-dep" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: robot-1-{{ . }}
  labels:
    app: robot-1-{{ . }}
    group: robot-1
    robotType: simulated
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: robot-1-{{ . }}
      group: robot-1
      robotType: simulated
  template:
    metadata:
      labels:
        app: robot-1-{{ . }}
        group: robot-1
        robotType: simulated
    spec:
      restartPolicy: Always
      {{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
      volumes:
       {{- include "zenoh-session-volumes" . }}
       {{- end }}
      containers:
        - name: world
          {{- include "simulation-image" .}}
          {{- include "lifecycle" .}}
          {{- if eq .Values.ros.rmw "rmw_zenoh_cpp" }}
          volumeMounts:
            {{- include "zenoh-session-volume-mount" . }}
          {{- end }}
          {{- include "ros-probes" . }}
          envFrom:
            {{- include "ros-common-env" . }}
            {{- include "robot-1-env" . }}
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-world-env
            - configMapRef:
                name: {{ .Release.Name }}-{{ .Release.Revision }}-launcher-{{ . }}-env
{{- end}}