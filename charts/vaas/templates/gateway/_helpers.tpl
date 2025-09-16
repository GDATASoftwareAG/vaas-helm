{{/*
Expand the name of the chart.
*/}}
{{- define "gateway.name" -}}
{{- default "gateway" .Values.gateway.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateway.fullname" -}}
{{- if .Values.gateway.fullnameOverride }}
{{- .Values.gateway.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.gateway.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "gateway.imagePullSecrets" -}}
{{- $ips := .Values.global.imagePullSecrets | default (list) -}}
{{- $hasIps := gt (len $ips) 0 -}}
{{- $hasLocal := .Values.imagePullSecret -}}
{{- $hasGlobalImagePullSecret := ((.Values.global).secret).imagePullSecret -}}
{{- $hasGlobalDockerconfig := ((.Values.global).secret).dockerconfigjson -}}

{{- if or $hasIps $hasLocal $hasGlobalImagePullSecret $hasGlobalDockerconfig }}
imagePullSecrets:
  {{- range $i, $entry := $ips }}
    {{- if not (kindIs "map" $entry) -}}
      {{- fail (printf "global.imagePullSecrets[%d] must be an object with 'name' (or 'secretName'), not %s" $i (kindOf $entry)) -}}
    {{- end -}}
    {{- $name := (get $entry "name") | default (get $entry "secretName") -}}
    {{- if not $name -}}
      {{- fail (printf "global.imagePullSecrets[%d] must contain key 'name' or 'secretName'. Got keys: %v" $i (keys $entry)) -}}
    {{- end }}
  - name: {{ $name }}
  {{- end }}

  {{- if $hasLocal }}
  - name: {{ include "gateway.fullname" . }}-image-pull-secret
  {{- end }}
  {{- if $hasGlobalImagePullSecret }}
  - name: {{ include "gateway.fullname" . }}-global-image-pull-secret
  {{- end }}
  {{- if $hasGlobalDockerconfig }}
  - name: {{ include "gateway.fullname" . }}-global-dockerconfigjson
  {{- end }}
{{- else -}}
{{- fail "You have to set at least one imagePullSecret: use global.imagePullSecrets (objects with 'name'/'secretName') or set imagePullSecret/global.secret.*" }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gateway.labels" -}}
helm.sh/chart: {{ include "gateway.chart" . }}
{{ include "gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "common.secondsToHHMMSS" -}}
{{- $totalSeconds := . -}}
{{- $hours := div $totalSeconds 3600 | printf "%02d" -}}
{{- $totalSeconds = mod $totalSeconds 3600 -}}
{{- $minutes := div $totalSeconds 60 | printf "%02d" -}}
{{- $seconds := mod $totalSeconds 60 | printf "%02d" -}}
{{- printf "%s:%s:%s" $hours $minutes $seconds -}}
{{- end -}}
