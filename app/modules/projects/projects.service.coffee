class ProjectsService extends taiga.Service
    @.$inject = ["$q", "$tgResources", "$rootScope", "$projectUrl"]

    constructor: (@q, @rs, @rootScope, @projectUrl) ->
        @.projects = {all: [], recent: []}
        @.inProgress = false
        @.projectsPromise = null
        @.fetchProjects()
        @.emiter = new EventEmitter2()

    fetchProjects: ->
        if not @.inProgress
            @.inProgress = true
            @.projectsPromise = @rs.projects.listByMember(@rootScope.user?.id).then (projects) =>
                for project in projects
                    project.url = @projectUrl.get(project)

                @.projects.recents = projects.slice(0, 8)
                @.projects.all = projects

                return @.projects

            @.projectsPromise.then () =>
                @.inProgress = false

        return @.projectsPromise

    newProject: ->
        @.emiter.emit("create")

    bulkUpdateProjectsOrder: (sortData) ->
        @rs.projects.bulkUpdateOrder(sortData).then =>
            @.fetchProjects()

angular.module("taigaProjects").service("tgProjects", ProjectsService)
