(function () {
    angular
        .module('scoutapi', ['ngRoute', 'ngResource'])
        .factory('authInterceptor', function (authService) {
            return {
                request: function (config) {
                    if (authService.getAuthorizationToken()) {
                        config.headers['Authorization'] = 'Token token="' + authService.getAuthorizationToken() + '", type="' + authService.getAuthorizationType() + '"';
                    }
                    return config;
                },
                requestError: function (config) {
                    return config;
                },
                response: function (res) {
                    if (res.headers("X-ScoutAPI-APIKey")) {
                        authService.setAPICredentials('apikey', res.headers("X-ScoutAPI-APIKey"));
                    }
                    return res;
                },
                responseError: function (res) {
                    alert(res.data + "\n" + res.status + " " + res.statusText);
                    return res;
                }
            }
        })
        .factory('CategoryModel', function ($resource) {
            return $resource('/api/v1/categories/:id', { id: '@id'}, {
                update: {
                    method: 'PUT'
                }
            });
        })
        .service('scoutapiService', function ($http) {
            var self = this;

            self.ping = function () {
                return $http.get('/api/v1/activities?featured=true')
            }

            self.readCategories = function () {
                return $http.get('/api/v1/categories')
            }

            self.readCategory = function (id) {
                return $http.get('/api/v1/categories/' + id)
            }

            self.getProfile = function () {
                return $http.get('/api/v1/users/profile')
            }
        })
        .service('authService', function () {
            var self = this;

            self.onIdentityProviderResponse = function (type, value) {
                self.setAPICredentials(type, value);
            }

            self.setAPICredentials = function (type, value) {
                self.authorizationType = type;
                self.authorizationToken = value;
            }

            self.getAuthorizationType = function () {
                return self.authorizationType || (window.googleIdToken ? "google" : "");
            }

            self.getAuthorizationToken = function () {
                return self.authorizationToken || window.googleIdToken;
            }
        })
        .config(function ($httpProvider) {
            $httpProvider.interceptors.push('authInterceptor');
        })
        .config(function ($routeProvider) {
            $routeProvider
                .when('/', {
                    controller: 'ScoutAPIController',
                    controllerAs: 'controller',
                    templateUrl: 'templates/dashboard.html'
                })
                .when('/categories', {
                    controller: 'CategoryController',
                    controllerAs: 'controller',
                    templateUrl: 'templates/categories.html'
                })
                .when('/categories/create', {
                    controller: 'CategoryCreateController',
                    controllerAs: 'controller',
                    templateUrl: 'templates/categories-create.html'
                })
                .when('/categories/:categoryId', {
                    controller: 'CategoryEditController',
                    controllerAs: 'controller',
                    templateUrl: 'templates/categories-update.html'
                })
                .otherwise('/');
        })
        .controller('ScoutAPIController', function (scoutapiService, authService) {
            var self = this;

            self.pingServer = function () {
                scoutapiService.ping().then(function (res) {
                    self.featuredCount = res.data.length;
                })
            }

            self.getProfile = function () {
                scoutapiService.getProfile().then(function (res) {
                    self.userName = res.data.display_name;
                    authService.setAPICredentials('apikey', res.data.keys[0].key);
                })
            }

            self.onIdentityProviderResponse = function (type, value) {
                authService.setAPICredentials(type, value);
                self.getProfile();
            }

        })
        .controller('CategoryController', function ($scope, scoutapiService, CategoryModel) {
            var self = this;

            $scope.categories = CategoryModel.query();
        })
        .controller('CategoryCreateController', function ($scope, $location, $routeParams, scoutapiService, CategoryModel) {
            var self = this;

            $scope.category = new CategoryModel();

            $scope.addCategory = function () {
                $scope.category.$save(function () {
                    $location.path("/categories");
                })
            };
        })
        .controller('CategoryEditController', function ($scope, $location, $routeParams, scoutapiService, CategoryModel) {
            var self = this;

            $scope.category = CategoryModel.get({id: $routeParams.categoryId});

            $scope.updateCategory = function () {
                $scope.category.$update(function () {
                    $location.path("/categories");
                })
            };

            $scope.deleteCategory = function () {
                if (confirm("Really delete " + $scope.category.name + "?")) {
                    $scope.category.$delete(function () {
                        $location.path("/categories");
                    })
                }
            };
        });
})
    ();