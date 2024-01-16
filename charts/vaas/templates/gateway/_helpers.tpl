{{/*
Expand the name of the chart.
*/}}
{{- define "gateway.name" -}}
{{- default .Chart.Name .Values.gateway.nameOverride | trunc 63 | trimSuffix "-" }}
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
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
  {{- end }}
  {{- if .Values.imagePullSecret }}
  - name: {{ .Release.Name }}-registry-secret
  {{- end }}
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
{{- end }}

{{/*
Create environment variables to configure gateway container.
*/}}
{{- define "gateway.env" }}
- name: Authentication__Schemes__Bearer__Authority
  value: {{.Values.gateway.authentication.authority}} 
- name: Authentication__Schemes__Bearer__RequireHttpsMetadata
  value: "false"
- name: Upload__Endpoint
  value: {{.Values.gateway.uploadUrl}}
- name: JwtSettings__Secret
  value: {{ randAlphaNum 64 }}
{{- if .Values.gateway.cloudhashlookup.enabled }}
- name: VerdictAsAService__Url
  value: {{ .Values.gateway.options.url | quote }}
- name: VerdictAsAService__TokenUrl
  value: {{ .Values.gateway.options.tokenurl | quote }}
- name: VerdictAsAService__Credentials__GrantType
  value: {{ .Values.gateway.options.credentials.granttype | quote }}
- name: VerdictAsAService__Credentials__ClientId
  value: {{ .Values.gateway.options.credentials.clientid | quote }}
- name: VerdictAsAService__Credentials__ClientSecret
  {{ toYaml .Values.gateway.options.credentials.clientsecret }}
{{- end }}
{{- end }}