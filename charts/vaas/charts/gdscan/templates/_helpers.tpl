{{/*
Expand the name of the chart.
*/}}
{{- define "gdscan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gdscan.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gdscan.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gdscan.labels" -}}
helm.sh/chart: {{ include "gdscan.chart" . }}
{{ include "gdscan.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "gdscan.imagePullSecrets" -}}

{{- $imagePullSecrets := concat (((.Values.global | default dict).imagePullSecrets)| default list) (.Values.imagePullSecrets | default list) -}}
{{- if gt (len $imagePullSecrets) 0 -}}
imagePullSecrets:
  {{- range $imagePullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gdscan.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gdscan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "common.names.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "vaas.claimName" -}}
{{- if and .Values.persistence.existingClaim }}
    {{- printf "%s" (tpl .Values.persistence.existingClaim $) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "common.storage.class" -}}

{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}

{{- end -}}

{{- define "common.secondsToHHMMSS" -}}
{{- $totalSeconds := . -}}
{{- $hours := div $totalSeconds 3600 | printf "%02d" -}}
{{- $totalSeconds = mod $totalSeconds 3600 -}}
{{- $minutes := div $totalSeconds 60 | printf "%02d" -}}
{{- $seconds := mod $totalSeconds 60 | printf "%02d" -}}
{{- printf "%s:%s:%s" $hours $minutes $seconds -}}
{{- end -}}
