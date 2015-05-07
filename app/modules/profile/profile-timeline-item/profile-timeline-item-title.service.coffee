class ProfileTimelineItemTitle
    @.$inject = [
        "$translate"
    ]

    _fieldTranslationKey: {
        'status': 'COMMON.FIELDS.STATUS',
        'subject': 'COMMON.FIELDS.SUBJECT',
        'description': 'COMMON.FIELDS.DESCRIPTION',
        'points': 'COMMON.FIELDS.POINTS',
        'severity': 'ISSUES.FIELDS.SEVERITY',
        'priority': 'ISSUES.FIELDS.PRIORITY',
        'type': 'ISSUES.FIELDS.TYPE',
        'is_iocaine': 'TASK.FIELDS.IS_IOCAINE'
    }

    constructor: (@translate) ->


    _translateTitleParams: (param, timeline, event) ->
        if param == "username"
            user = timeline.data.user
            title_attr = @translate.instant('COMMON.SEE_USER_PROFILE', {username: user.username})
            url = 'user-profile:username=vm.activity.user.username'
            console.log(user)
            return @._getLink(url, user.name, title_attr)

        else if param == 'field_name'
            field_name = Object.keys(timeline.data.values_diff)[0]

            return @translate.instant(@._fieldTranslationKey[field_name])

        else if param == 'project_name'
            url = 'project:project=vm.activity.project.slug'

            return @._getLink(url, timeline.data.project.name)

        else if param == 'sprint_name'
            url = 'project-taskboard:project=vm.activity.project.slug,sprint=vm.activity.sprint.slug'

            return @._getLink(url, timeline.data.milestone.name)

        else if param == 'obj_name'
            obj = @._getTimelineObj(timeline, event)
            url = @._getDetailObjUrl(event)

            if event.obj == 'wikipage'
                text = obj.slug
            else if event.obj == 'milestone'
                text = obj.name
            else
                text = '#' + obj.ref + ' ' + obj.subject

            return @._getLink(url, text)

    _getTimelineObj: (timeline, event) ->
        return timeline.data[event.obj]

    _getDetailObjUrl: (event) ->
        url = {
            "issue": ["project-issues-detail", ":project=vm.activity.project.slug,ref=vm.activity.obj.ref"],
            "wikipage": ["project-wiki-page", ":project=vm.activity.project.slug,slug=vm.activity.obj.slug"],
            "task": ["project-tasks-detail", ":project=vm.activity.project.slug,ref=vm.activity.obj.ref"],
            "userstory": ["project-userstories-detail", ":project=vm.activity.project.slug,ref=vm.activity.obj.ref"],
            "milestone": ["project-taskboard", ":project=vm.activity.project.slug,sprint=vm.activity.obj.slug"]
        }

        return url[event.obj][0] + url[event.obj][1]

    _getLink: (url, text, title) ->
        title = title || text

        return $('<a>')
            .attr('tg-nav', url)
            .text(text)
            .attr('title', title)
            .prop('outerHTML')

    _getParams: (timeline, event, timeline_type) ->
        params = {}

        timeline_type.translate_params.forEach (param) =>
            params[param] = @._translateTitleParams(param, timeline, event)

        return params

    getTitle: (timeline, event, type) ->
        return @translate.instant(type.key, @._getParams(timeline, event, type))

angular.module("taigaProfile")
    .service("tgProfileTimelineItemTitle", ProfileTimelineItemTitle)
