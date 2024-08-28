{{- define "vaas.sentryEnvironmentVariables" }}
{{- if .Values.sentry }}
{{- if .Values.sentry.environment }}
- name: Sentry__Environment
  value: {{ .Values.sentry.environment | quote }}
{{- end }}        
{{- if .Values.sentry.dsn }}
- name: Sentry__Dsn
  value: {{ .Values.sentry.dsn | quote }}
{{- end }}        
{{- if .Values.sentry.release }}
- name: Sentry__Release
  value: {{ .Values.sentry.release | quote }}
{{- end }}        
{{- if .Values.sentry.maxBreadcrumbs }}
- name: Sentry__MaxBreadcrumbs
  value: {{ .Values.sentry.maxBreadcrumbs | quote }}
{{- end }}        
{{- if .Values.sentry.maxQueueItems }}              
- name: Sentry__MaxQueueItems
  value: {{ .Values.sentry.maxQueueItems | quote }}
{{- end }}        
{{- if .Values.sentry.enableTracing }}              
- name: Sentry__EnableTracing
  value: {{ .Values.sentry.enableTracing | quote }}
{{- end }}        
{{- if .Values.sentry.tracesSampleRate }}         
- name: Sentry__TracesSampleRate
  value: {{ .Values.sentry.tracesSampleRate | quote }}
{{- end }}
{{- end }}
{{- end }}
