###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: app.coffee
###

@taiga = taiga = {}
@.taigaContribPlugins = @.taigaContribPlugins or []

# Generic function for generate hash from a arbitrary length
# collection of parameters.
taiga.generateHash = (components=[]) ->
    components = _.map(components, (x) -> JSON.stringify(x))
    return hex_sha1(components.join(":"))

taiga.generateUniqueSessionIdentifier = ->
    date = (new Date()).getTime()
    randomNumber = Math.floor(Math.random() * 0x9000000)
    return taiga.generateHash([date, randomNumber])

taiga.sessionId = taiga.generateUniqueSessionIdentifier()


configure = ($routeProvider, $locationProvider, $httpProvider, $provide, $tgEventsProvider, tgLoaderProvider,
             $compileProvider, $translateProvider) ->
    $routeProvider.when("/",
        {templateUrl: "project/projects.html", resolve: {loader: tgLoaderProvider.add()}})

    $routeProvider.when("/project/:pslug/",
        {templateUrl: "project/project.html"})

    $routeProvider.when("/project/:pslug/search",
        {templateUrl: "search/search.html", reloadOnSearch: false})

    $routeProvider.when("/project/:pslug/backlog",
        {templateUrl: "backlog/backlog.html", resolve: {loader: tgLoaderProvider.add()}})

    $routeProvider.when("/project/:pslug/kanban",
        {templateUrl: "kanban/kanban.html", resolve: {loader: tgLoaderProvider.add()}})

    # Milestone
    $routeProvider.when("/project/:pslug/taskboard/:sslug",
        {templateUrl: "taskboard/taskboard.html", resolve: {loader: tgLoaderProvider.add()}})

    # User stories
    $routeProvider.when("/project/:pslug/us/:usref",
        {templateUrl: "us/us-detail.html", resolve: {loader: tgLoaderProvider.add()}})

    # Tasks
    $routeProvider.when("/project/:pslug/task/:taskref",
        {templateUrl: "task/task-detail.html", resolve: {loader: tgLoaderProvider.add()}})

    # Wiki
    $routeProvider.when("/project/:pslug/wiki",
        {redirectTo: (params) -> "/project/#{params.pslug}/wiki/home"}, )
    $routeProvider.when("/project/:pslug/wiki/:slug",
        {templateUrl: "wiki/wiki.html", resolve: {loader: tgLoaderProvider.add()}})

    # Team
    $routeProvider.when("/project/:pslug/team",
        {templateUrl: "team/team.html", resolve: {loader: tgLoaderProvider.add()}})

    # Issues
    $routeProvider.when("/project/:pslug/issues",
        {templateUrl: "issue/issues.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/issue/:issueref",
        {templateUrl: "issue/issues-detail.html", resolve: {loader: tgLoaderProvider.add()}})

    # Admin - Project Profile
    $routeProvider.when("/project/:pslug/admin/project-profile/details",
        {templateUrl: "admin/admin-project-profile.html"})
    $routeProvider.when("/project/:pslug/admin/project-profile/default-values",
        {templateUrl: "admin/admin-project-default-values.html"})
    $routeProvider.when("/project/:pslug/admin/project-profile/modules",
        {templateUrl: "admin/admin-project-modules.html"})
    $routeProvider.when("/project/:pslug/admin/project-profile/export",
        {templateUrl: "admin/admin-project-export.html"})
    $routeProvider.when("/project/:pslug/admin/project-profile/reports",
        {templateUrl: "admin/admin-project-reports.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/status",
        {templateUrl: "admin/admin-project-values-status.html"})
    $routeProvider.when("/project/:pslug/admin/project-values/points",
        {templateUrl: "admin/admin-project-values-points.html"})
    $routeProvider.when("/project/:pslug/admin/project-values/priorities",
        {templateUrl: "admin/admin-project-values-priorities.html"})
    $routeProvider.when("/project/:pslug/admin/project-values/severities",
        {templateUrl: "admin/admin-project-values-severities.html"})
    $routeProvider.when("/project/:pslug/admin/project-values/types",
        {templateUrl: "admin/admin-project-values-types.html"})
    $routeProvider.when("/project/:pslug/admin/project-values/custom-fields",
        {templateUrl: "admin/admin-project-values-custom-fields.html"})

    $routeProvider.when("/project/:pslug/admin/memberships",
        {templateUrl: "admin/admin-memberships.html"})
    # Admin - Roles
    $routeProvider.when("/project/:pslug/admin/roles",
        {templateUrl: "admin/admin-roles.html"})
    # Admin - Third Parties
    $routeProvider.when("/project/:pslug/admin/third-parties/webhooks",
        {templateUrl: "admin/admin-third-parties-webhooks.html"})
    $routeProvider.when("/project/:pslug/admin/third-parties/github",
        {templateUrl: "admin/admin-third-parties-github.html"})
    $routeProvider.when("/project/:pslug/admin/third-parties/gitlab",
        {templateUrl: "admin/admin-third-parties-gitlab.html"})
    $routeProvider.when("/project/:pslug/admin/third-parties/bitbucket",
        {templateUrl: "admin/admin-third-parties-bitbucket.html"})
    # Admin - Contrib Plugins
    $routeProvider.when("/project/:pslug/admin/contrib/:plugin",
        {templateUrl: "contrib/main.html"})

    # User settings
    $routeProvider.when("/project/:pslug/user-settings/user-profile",
        {templateUrl: "user/user-profile.html"})
    $routeProvider.when("/project/:pslug/user-settings/user-change-password",
        {templateUrl: "user/user-change-password.html"})
    $routeProvider.when("/project/:pslug/user-settings/user-avatar",
        {templateUrl: "user/user-avatar.html"})
    $routeProvider.when("/project/:pslug/user-settings/mail-notifications",
        {templateUrl: "user/mail-notifications.html"})
    $routeProvider.when("/change-email/:email_token",
        {templateUrl: "user/change-email.html"})
    $routeProvider.when("/cancel-account/:cancel_token",
        {templateUrl: "user/cancel-account.html"})

    # User profile
    $routeProvider.when("/profile",
     {templateUrl: "home/home-logged-in.html"})

    # Auth
    $routeProvider.when("/login",
        {templateUrl: "auth/login.html"})
    $routeProvider.when("/register",
        {templateUrl: "auth/register.html"})
    $routeProvider.when("/forgot-password",
        {templateUrl: "auth/forgot-password.html"})
    $routeProvider.when("/change-password",
        {templateUrl: "auth/change-password-from-recovery.html"})
    $routeProvider.when("/change-password/:token",
        {templateUrl: "auth/change-password-from-recovery.html"})
    $routeProvider.when("/invitation/:token",
        {templateUrl: "auth/invitation.html"})

    # Errors/Exceptions
    $routeProvider.when("/error",
        {templateUrl: "error/error.html"})
    $routeProvider.when("/not-found",
        {templateUrl: "error/not-found.html"})
    $routeProvider.when("/permission-denied",
        {templateUrl: "error/permission-denied.html"})

    $routeProvider.otherwise({redirectTo: "/not-found"})
    $locationProvider.html5Mode({enabled: true, requireBase: false})

    defaultHeaders = {
        "Content-Type": "application/json"
        "Accept-Language": window.taigaConfig.defaultLanguage || "en"
        "X-Session-Id": taiga.sessionId
    }

    $httpProvider.defaults.headers.delete = defaultHeaders
    $httpProvider.defaults.headers.patch = defaultHeaders
    $httpProvider.defaults.headers.post = defaultHeaders
    $httpProvider.defaults.headers.put = defaultHeaders
    $httpProvider.defaults.headers.get = {
        "X-Session-Id": taiga.sessionId
    }

    $tgEventsProvider.setSessionId(taiga.sessionId)

    # Add next param when user try to access to a secction need auth permissions.
    authHttpIntercept = ($q, $location, $navUrls, $lightboxService) ->
        httpResponseError = (response) ->
            if response.status == 0
                $lightboxService.closeAll()
                $location.path($navUrls.resolve("error"))
                $location.replace()
            else if response.status == 401
                nextPath = $location.path()
                $location.url($navUrls.resolve("login")).search("next=#{nextPath}")

            return $q.reject(response)

        return {
            responseError: httpResponseError
        }

    $provide.factory("authHttpIntercept", ["$q", "$location", "$tgNavUrls", "lightboxService",
                                           authHttpIntercept])

    $httpProvider.interceptors.push("authHttpIntercept")

    # If there is an error in the version throw a notify error.
    # IMPROVEiMENT: Move this version error handler to USs, issues and tasks repository
    versionCheckHttpIntercept = ($q) ->
        httpResponseError = (response) ->
            if response.status == 400 && response.data.version
                # HACK: to prevent circular dependencies with [$tgConfirm, $translate]
                $injector = angular.element("body").injector()
                $injector.invoke(["$tgConfirm", "$translate", ($confirm, $translate) =>
                    versionErrorMsg = $translate.instant("ERROR.VERSION_ERROR")
                    $confirm.notify("error", versionErrorMsg, null, 10000)
                ])

            return $q.reject(response)

        return {responseError: httpResponseError}

    $provide.factory("versionCheckHttpIntercept", ["$q", versionCheckHttpIntercept])

    $httpProvider.interceptors.push("versionCheckHttpIntercept")

    window.checksley.updateValidators({
        linewidth: (val, width) ->
            lines = taiga.nl2br(val).split("<br />")

            valid = _.every lines, (line) ->
                line.length < width

            return valid
    })

    $compileProvider.debugInfoEnabled(window.taigaConfig.debugInfo || false)

    if localStorage.userInfo
        userInfo = JSON.parse(localStorage.userInfo)

    # i18n
    preferedLangCode = userInfo?.lang || window.taigaConfig.defaultLanguage || "en"

    $translateProvider
        .useStaticFilesLoader({
            prefix: "/locales/locale-",
            suffix: ".json"
        })
        .addInterpolation('$translateMessageFormatInterpolation')
        .preferredLanguage(preferedLangCode)

    if not window.taigaConfig.debugInfo
        $translateProvider.fallbackLanguage(preferedLangCode)


i18nInit = (lang, $translate) ->
    # i18n - moment.js
    moment.locale(lang)

    # i18n - checksley.js
    messages = {
        defaultMessage: $translate.instant("COMMON.FORM_ERRORS.DEFAULT_MESSAGE")
        type: {
            email: $translate.instant("COMMON.FORM_ERRORS.TYPE_EMAIL")
            url: $translate.instant("COMMON.FORM_ERRORS.TYPE_URL")
            urlstrict: $translate.instant("COMMON.FORM_ERRORS.TYPE_URLSTRICT")
            number: $translate.instant("COMMON.FORM_ERRORS.TYPE_NUMBER")
            digits: $translate.instant("COMMON.FORM_ERRORS.TYPE_DIGITS")
            dateIso: $translate.instant("COMMON.FORM_ERRORS.TYPE_DATEISO")
            alphanum: $translate.instant("COMMON.FORM_ERRORS.TYPE_ALPHANUM")
            phone: $translate.instant("COMMON.FORM_ERRORS.TYPE_PHONE")
        }
        notnull: $translate.instant("COMMON.FORM_ERRORS.NOTNULL")
        notblank: $translate.instant("COMMON.FORM_ERRORS.NOT_BLANK")
        required: $translate.instant("COMMON.FORM_ERRORS.REQUIRED")
        regexp: $translate.instant("COMMON.FORM_ERRORS.REGEXP")
        min: $translate.instant("COMMON.FORM_ERRORS.MIN")
        max: $translate.instant("COMMON.FORM_ERRORS.MAX")
        range: $translate.instant("COMMON.FORM_ERRORS.RANGE")
        minlength: $translate.instant("COMMON.FORM_ERRORS.MIN_LENGTH")
        maxlength: $translate.instant("COMMON.FORM_ERRORS.MAX_LENGTH")
        rangelength: $translate.instant("COMMON.FORM_ERRORS.RANGE_LENGTH")
        mincheck: $translate.instant("COMMON.FORM_ERRORS.MIN_CHECK")
        maxcheck: $translate.instant("COMMON.FORM_ERRORS.MAX_CHECK")
        rangecheck: $translate.instant("COMMON.FORM_ERRORS.RANGE_CHECK")
        equalto: $translate.instant("COMMON.FORM_ERRORS.EQUAL_TO")
    }
    checksley.updateMessages('default', messages)


init = ($log, $config, $rootscope, $auth, $events, $analytics, $translate) ->
    $log.debug("Initialize application")

    # Taiga Plugins
    $rootscope.contribPlugins = @.taigaContribPlugins
    $rootscope.adminPlugins = _.where(@.taigaContribPlugins, {"type": "admin"})

    $rootscope.$on "$translateChangeEnd", (e, ctx) ->
        lang = ctx.language
        i18nInit(lang, $translate)

    # Load user
    if $auth.isAuthenticated()
        $events.setupConnection()
        user = $auth.getUser()

    # Analytics
    $analytics.initialize()


modules = [
    # Main Global Modules
    "taigaBase",
    "taigaCommon",
    "taigaResources",
    "taigaAuth",
    "taigaEvents",

    # Specific Modules
    "taigaRelatedTasks",
    "taigaBacklog",
    "taigaTaskboard",
    "taigaKanban",
    "taigaIssues",
    "taigaUserStories",
    "taigaTasks",
    "taigaTeam",
    "taigaWiki",
    "taigaSearch",
    "taigaAdmin",
    "taigaNavMenu",
    "taigaProject",
    "taigaUserSettings",
    "taigaFeedback",
    "taigaPlugins",
    "taigaIntegrations",
    "taigaComponents",
    "taigaProfile",

    # template cache
    "templates",

    # Vendor modules
    "ngRoute",
    "ngAnimate",
    "pascalprecht.translate"
].concat(_.map(@.taigaContribPlugins, (plugin) -> plugin.module))

# Main module definition
module = angular.module("taiga", modules)

module.config([
    "$routeProvider",
    "$locationProvider",
    "$httpProvider",
    "$provide",
    "$tgEventsProvider",
    "tgLoaderProvider",
    "$compileProvider",
    "$translateProvider",
    configure
])

module.run([
    "$log",
    "$tgConfig",
    "$rootScope",
    "$tgAuth",
    "$tgEvents",
    "$tgAnalytics",
    "$translate"
    init
])
