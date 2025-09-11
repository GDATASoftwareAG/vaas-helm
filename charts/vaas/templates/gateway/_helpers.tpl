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
    {{- if kindIs "string" $entry }}
  - name: {{ $entry }}
    {{- else if kindIs "map" $entry }}
      {{- if hasKey $entry "name" }}
  - name: {{ get $entry "name" }}
      {{- else if hasKey $entry "secretName" }}
  - name: {{ get $entry "secretName" }}
      {{- else }}
      {{- fail (printf "global.imagePullSecrets[%d] must have key 'name' (or 'secretName'). Got keys: %v" $i (keys $entry)) }}
      {{- end }}
    {{- else }}
    {{- fail (printf "global.imagePullSecrets[%d] has unsupported kind %s (type %s)" $i (kindOf $entry) (typeOf $entry)) }}
    {{- end }}
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
{{- fail "You have to set at least one imagePullSecret (global.imagePullSecrets, imagePullSecret, global.secret.imagePullSecret or global.secret.dockerconfigjson)" }}
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
