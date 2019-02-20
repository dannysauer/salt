from __future__ import absolute_import


def __virtual__():
    return "caasp_orch"


def sync_all():
    '''
    Syncronize everything before starting a new orchestration
    '''
    # note well: this could trigger some race conditions until fixed in Salt
    #            see https://github.com/openSUSE/salt/pull/130
    # __utils__['caasp_log.debug']('orch: refreshing all')
    # __salt__['saltutil.sync_all'](refresh=True)

    __utils__['caasp_log.debug']('orch: synchronizing the mine')
    __salt__['saltutil.runner']('mine.update', tgt='*', clear=True)
