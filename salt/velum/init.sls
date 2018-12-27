include:
  - etc-hosts
  - crypto

{% set names = [salt.caasp_pillar.get('dashboard_external_fqdn'),
                salt.caasp_pillar.get('dashboard')] %}

{% if salt.caasp_pillar.get('external_cert:velum:cert', False)
  and salt.caasp_pillar.get('external_cert:velum:key',  False)
%}

{{ pillar['ssl']['velum_crt'] }}
  file.managed:
    - user:  root
    - group: root
    - mode: 0644
    - contents_pillar: external_cert:velum:cert

{{ pillar['ssl']['velum_key'] }}
  file.managed:
    - user:  root
    - group: root
    - mode: 0444
    - contents_pillar: external_cert:velum:key
    
{% else %}

{% from '_macros/certs.jinja' import alt_names, certs with context %}
{{ certs("velum:" + grains['nodename'],
         pillar['ssl']['velum_crt'],
         pillar['ssl']['velum_key'],
         cn = grains['nodename'],
         extra_alt_names = alt_names(names)) }}

{% endif %}
