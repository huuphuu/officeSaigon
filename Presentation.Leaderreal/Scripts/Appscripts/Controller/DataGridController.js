angular.module('indexApp')
.controller('dataGridCtrl', dataGridsCtrl)

function dataGridsCtrl(DTOptionsBuilder, DTColumnDefBuilder, DTColumnBuilder, $scope, coreService, $rootScope, $http) {
    //-------------------------------------
    // bo comment neu up len server --------------------------------------------------------------------------
    //-------------------------------------

    //console.log('$scope--------------------------------', $scope, gridService);

    //var vm = this;
    //vm.gridData = [];

    //vm.dtOptions = DTOptionsBuilder.newOptions()
    //     .withOption("paging", true)
    //     .withOption("pagingType", 'simple_numbers')
    //     .withOption("pageLength", 9)
    //     .withOption("searching", true)
    //    .withOption("autowidth", false);
    ////  .withLanguageSource('Scripts/plugins/datatables/LanguageSource.json');

    //$rootScope.$on('changeGridData', function (event, data) {
    //    console.log('data', data);
    //    vm.gridInfo.data = angular.copy(data);
    //});

    //vm.init = function (gridInfo, rootScope) {
    //    vm.gridInfo = gridInfo;
    //    vm.rootScope = rootScope;
    //    $rootScope.showModal = true;
    //    if ($rootScope.searchEntryFilter == null || typeof $rootScope.searchEntryFilter == 'undefined') {
    //        coreService.getList($scope.gridInfo.sysViewID, function (data) {
    //            vm.gridInfo.data = angular.copy(data[1]);
    //            $rootScope.showModal = false;
    //            $scope.$apply();
    //        });
    //    }


    //    angular.forEach($scope.gridInfo.cols, function (value, key) {
    //        if (typeof value != "function" && typeof value != "object") {
    //            // value = html.decode(value);
    //            inputs.push($.string.Format('{0}="{1}" ', key, objThis.html.encode(value)));
    //        }
    //    });
    //    vm.dtColumnDefs = [];
    //    var x, k = 0, cols = $scope.gridInfo.cols, arr = new Array();
    //    for (x in cols) {
    //        if (typeof cols[x].isSort == 'undefined')
    //            cols[x].isSort = true;
    //        if (cols[x].isSort == false)
    //            vm.dtColumnDefs.push(DTColumnDefBuilder.newColumnDef(k++).notSortable());
    //        else
    //            vm.dtColumnDefs.push(DTColumnDefBuilder.newColumnDef(k++));
    //    }

    //}
    //vm.setData = function (item, col) {
    //    var row = angular.copy(item);
    //    if (angular.isFunction(vm.rootScope.setData)) {
    //        vm.rootScope.setData(row, col);
    //    }
    //}
    //vm.dtInstanceCallback = function (dtInstance) {
    //    var datatableObj = dtInstance.DataTable;
    //    $scope.gridInfo.tableInstance = datatableObj;
    //};
    //$scope.searchTable = function () {
    //    var query = $scope.searchQuery;

    //    $scope.gridInfo.tableInstance.search(query).draw();
    //};


    //new configuration for server side processing
    var vm = this;
    vm.gridData = [];
    vm.rowsPerPage = 20;

    vm.dtOptions = DTOptionsBuilder.newOptions()
        //.withOption('ajax', {
        //    //dataSrc: "data",
        //    dataSrc: function (json) {
        //        console.log('json', json);
        //        return json;
        //    },
        //    url: "/service.data/Core/CoreService.asmx/GetContextData",
        //    type: "POST",
        //    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        //    data: function (data, dtInstance) {
        //        // Modify the data object properties here before being passed to the server
        //        data.Sys_ViewID = vm.gridInfo.sysViewID;
        //        var newRequest = { inputValue: coreService.convertServerDataProcessing(data), clientKey: '' };
        //        return newRequest;
        //    },
        //    fnServerData: function (data) {
        //        console.log('data response', data);
        //    },
        //    success: function (data) {
        //        console.log('data response', data);
        //    }
        //})
    .withOption('ajax', function (data, callback, settings) {
        data.Sys_ViewID = vm.gridInfo.sysViewID;
        data.length = vm.rowsPerPage;
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
                        data = pData[1];
                        totalRow = pData[2][0].TotalRow;
                    }
            //  console.log('res', data);
            callback({
                //recordsTotal: res.meta.total_count,
                //recordsFiltered: res.meta.total_count,
                //  data: res.objects
                recordsTotal: totalRow,
                recordsFiltered: totalRow,
                data: data
            });
            $rootScope.showModal = false;
        }, function errorCallback(response) {
            console.log('error', response);
            // called asynchronously if an error occurs
            // or server returns response with an error status.
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
        .withOption("autowidth", false);
    //  .withLanguageSource('Scripts/plugins/datatables/LanguageSource.json');


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
        //sort
        for (x in cols) {
            if (typeof cols[x].isSort == 'undefined')
                cols[x].isSort = true;
            if (cols[x].isSort == false) {
                if (typeof cols[x].isHidden == 'undefined')
                    cols[x].isHidden = false;
                if (cols[x].isHidden == false)
                    vm.dtColumns.push(DTColumnBuilder.newColumn(cols[x].name, cols[x].heading).withOption(cols[x].name, cols[x].heading).notSortable());
                else
                    vm.dtColumns.push(DTColumnBuilder.newColumn(cols[x].name, cols[x].heading).withOption(cols[x].name, cols[x].heading).notSortable().notVisible());
            } else {
                if (typeof cols[x].isHidden == 'undefined')
                    cols[x].isHidden = false;
                if (cols[x].isHidden == false)
                    vm.dtColumns.push(DTColumnBuilder.newColumn(cols[x].name, cols[x].heading).withOption(cols[x].name, cols[x].heading));
                else
                    vm.dtColumns.push(DTColumnBuilder.newColumn(cols[x].name, cols[x].heading).withOption(cols[x].name, cols[x].heading).notVisible());
            }

        }
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
    };
    $scope.searchTable = function () {
        var query = $scope.searchQuery;

        $scope.gridInfo.tableInstance.search(query).draw();
    };


}
