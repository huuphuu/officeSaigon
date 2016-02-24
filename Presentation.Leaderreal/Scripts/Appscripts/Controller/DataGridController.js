angular.module('indexApp')
.controller('dataGridCtrl', dataGridsCtrl)

function dataGridsCtrl(DTOptionsBuilder, DTColumnDefBuilder, DTColumnBuilder, $scope, coreService, $rootScope, $http, $compile) {
    //new configuration for server side processing
    var vm = this;
    vm.gridData = [];
    vm.rowsPerPage = 20;
    vm.dtInstances = [];

    vm.dtOptions = DTOptionsBuilder.newOptions()
    .withOption('ajax', function (data, callback, settings) {
        if (typeof $rootScope.searchEntryFilter != 'undefined' && $rootScope.searchEntryFilter != null)
            addSearchValueToData(data, $rootScope.searchEntryFilter);

        data.Sys_ViewID = vm.gridInfo.sysViewID;
        data.length = vm.rowsPerPage;
        vm.gridInfo.dtInstances = vm.dtInstances;
        var newRequest = { 'inputValue': coreService.convertServerDataProcessing(data), 'clientKey': '' };

        $http({
            method: 'POST',
            url: '/service.data/Core/CoreService.asmx/GetContextData',
            //headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            data: newRequest
        }).then(function successCallback(res) {
            
            var data = [], totalRow = 0;
            if (typeof res != 'undefined')
                if (typeof res.data != 'undefined')
                    if (typeof res.data.d != 'undefined') {
                        var pData = res.data.d;
                        pData = pData.CSV2JSON2();
                        console.log('res', pData);
                        data = pData[1];
                        totalRow = pData[2][0].TotalRow;
                    }
              
            callback({
                recordsTotal: totalRow,
                recordsFiltered: totalRow,
                data: data
            });
            $rootScope.showModal = false;
        }, function errorCallback(response) {
            console.log('error', response);
        })
    })
        .withDataProp('data') // server side processing
        .withOption('processing', true) // show server side processing loading
        .withOption('serverSide', true) // server side processing
        .withOption('aaSorting', [0, 'asc']) // for default sorting column // here 0 means first column
        .withOption("paging", true)
        .withOption("pagingType", 'simple_numbers')
        .withOption("pageLength", vm.rowsPerPage)
        .withOption("searching", true)
        .withOption("autowidth", false)
        .withOption('fnRowCallback', function (nRow) {
                        $compile(nRow)($scope);
                        //$('td', nRow).attr('nowrap', 'nowrap');
                        //return nRow;
                    })
    //  .withLanguageSource('Scripts/plugins/datatables/LanguageSource.json');

    function addSearchValueToData(originalDataObj, searchObj) {
        angular.forEach(searchObj, function (value, key) {
            originalDataObj[key] = value;
        });
    }

    vm.init = function (gridInfo, rootScope) {
        vm.gridInfo = gridInfo;
        vm.rootScope = rootScope;
        $rootScope.showModal = true;
        //if ($rootScope.searchEntryFilter == null || typeof $rootScope.searchEntryFilter == 'undefined') {
        //    coreService.getList($scope.gridInfo.sysViewID, function (data) {
        //        vm.gridInfo.data = angular.copy(data[1]);
        //        $rootScope.showModal = false;
        //        $scope.$apply();
        //    });
        //}


        angular.forEach($scope.gridInfo.cols, function (value, key) {
            if (typeof value != "function" && typeof value != "object") {
                // value = html.decode(value);
                inputs.push($.string.Format('{0}="{1}" ', key, objThis.html.encode(value)));
            }
        });

        vm.dtColumns = [];
        var x, k = 0, cols = $scope.gridInfo.cols, arr = new Array();
        //sort, isHidden
        for (x in cols) {
            if (cols[x].type == controls.LIST_ICON);
            else {
                if (typeof cols[x].className == 'undefined')
                    cols[x].className = '';
                if (typeof cols[x].width == 'undefined')
                    cols[x].width = 'auto';
                if (typeof cols[x].isSort == 'undefined')
                    cols[x].isSort = false;
                if (cols[x].isSort == false) {
                    if (typeof cols[x].isHidden == 'undefined')
                        cols[x].isHidden = false;
                    if (cols[x].isHidden == false)
                        vm.dtColumns.push(
                            DTColumnBuilder.newColumn(cols[x].name, cols[x].heading)
                            .withOption(cols[x].name, cols[x].heading)
                            .withOption('className', cols[x].className)
                            .withOption('width', cols[x].width)
                            .notSortable());
                    else
                        vm.dtColumns.push(
                            DTColumnBuilder.newColumn(cols[x].name, cols[x].heading)
                            .withOption(cols[x].name, cols[x].heading)
                            .withOption('className', cols[x].className)
                            .withOption('width', cols[x].width)
                            .notSortable()
                            .notVisible());
                } else {
                    if (typeof cols[x].isHidden == 'undefined')
                        cols[x].isHidden = false;
                    if (cols[x].isHidden == false)
                        vm.dtColumns.push(DTColumnBuilder.newColumn(
                            cols[x].name, cols[x].heading)
                            .withOption(cols[x].name, cols[x].heading)
                            .withOption('className', cols[x].className)
                            .withOption('width', cols[x].width));
                    else
                        vm.dtColumns.push(
                            DTColumnBuilder.newColumn(cols[x].name, cols[x].heading)
                            .withOption(cols[x].name, cols[x].heading)
                            .withOption('className', cols[x].className)
                            .withOption('width', cols[x].width)
                            .notVisible());
                }
            }


        }
        if (cols[x].type == controls.LIST_ICON)
            vm.dtColumns.push(standardField2Column(cols[x]));
    }

    function standardField2Column(field) {
        var col = DTColumnBuilder.newColumn(field.name);
        col.withTitle(field.heading);
        col.notSortable();
        if (typeof field.className == 'undefined')
            field.className = '';
        col.withClass(field.name + " " + field.className);
        switch (field.type) {
            //case controls.ICON_AND_TEXT:
            //    col.notSortable();
            //    col.renderWith(function (data, type, full, meta) {

            //        return [
            //           //'<i  ng-click="action(data,field)" class="fa ', field.classIcon, '">&nbsp;&nbsp;', data, '</i>'
            //            '<i  ng-click="action(', full.ID, ",\'", field.name, '\')" class="fa ', field.classIcon, '">&nbsp;&nbsp;', data, '</i>'
            //        ].join('');
            //    });
            //    break;

            case controls.LIST_ICON:
                col.notSortable();
                col.renderWith(function (data, type, full, meta) {
                    var result = '';
                    angular.forEach(field.listAction, function (value, key) {
                        result += '<a href="" ng-click="vm.actionClick(' + full.ID + ",\'" + value.action + '\',this)" >' +
                            '<i  class="fa ' + value.classIcon + '">&nbsp;&nbsp;' + '</i>' +
                            '</a>';
                    });

                    return result;
                });
                break;

            default:

                break;
        }

        return col;

    }

    vm.actionClick = function (row, act, obj) {
        $scope.gridInfo.onActionClick(row, act);
    }

    vm.setData = function (item, col) {
        var row = angular.copy(item);
        if (angular.isFunction(vm.rootScope.setData)) {
            vm.rootScope.setData(row, col);
        }
    }
    vm.dtInstanceCallback = function (dtInstance) {
        var datatableObj = dtInstance.DataTable;
        $scope.gridInfo.tableInstance = datatableObj;
        $scope.gridInfo.dtInstance = dtInstance;
    };

    $scope.searchTable = function () {
        var query = $scope.searchQuery;

        $scope.gridInfo.tableInstance.search(query).draw();
    };


}
