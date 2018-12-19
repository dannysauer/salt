{%- set updates_all_target = 'P@roles:(admin|etcd|kube-(master|minion)) and ' +
                             'not G@update_in_progress:true and ' +
                             'not G@removal_in_progress:true and ' +
                             'not G@force_removal_in_progress:true' %}

{%- if salt.saltutil.runner('mine.get', tgt=updates_all_target, fun='nodename', tgt_type='compound')|length > 0 %}
update_pillar:
  salt.function:
    - tgt: {{ updates_all_target }}
    - tgt_type: compound
    - name: saltutil.refresh_pillar

update_grains:
  salt.function:
    - tgt: {{ updates_all_target }}
    - tgt_type: compound
    - name: saltutil.refresh_grains

update_mine:
  salt.function:
    - tgt: {{ updates_all_target }}
    - tgt_type: compound
    - name: mine.update
    - require:
      - salt: update_pillar
      - salt: update_grains

# update the CA list first
# this one should require the update_mine, then the others can require the CA
# TODO: also update the per-app logic to depend on CA update happening

# run just the states managing systems where external certs are used
update_certs_velum:
  salt.state:
    # admin only
    - tgt: {{ updates_all_target + ' and P@roles:(admin)' }}
    - tgt_type: compound
    - kwarg:
        queue: True
    - sls:
      - velum
    - require:
      - salt: update_mine

update_certs_dex:
  salt.state:
    # TODO: is there a target definition for where Dex should be?
    - tgt: {{ updates_all_target + ' and P@roles:(kube-(master|minion))' }}
    - tgt_type: compound
    - kwarg:
        queue: True
    - sls:
      - addons.dex
    - require:
      - salt: update_mine
{% endif %}
