angular.module('indexApp')
.controller('dataGridCtrl', dataGridsCtrl)
function dataGridsCtrl(DTOptionsBuilder, DTColumnDefBuilder, DTColumnBuilder, $scope, coreService, $rootScope) {
    //new configuration for server side processing
    var vm = this;
    vm.gridData = [];

    vm.dtOptions = DTOptionsBuilder.newOptions()
        .withOption('ajax', {
            dataSrc: "data",
            url: "/service.data/Core/CoreService.asmx/GetContextData",
            type: "POST",
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: function (data, dtInstance) {
                // Modify the data object properties here before being passed to the server
                // anh Phu xem o day
                console.log('data', data, typeof data);
                data = coreService.convertServerDataProcessing(data);
                console.log('data after', data, typeof data);
            }
        })
        .withDataProp('data') // server side processing
        .withOption('processing', true) // show server side processing loading
        .withOption('serverSide', true) // server side processing
        .withOption('aaSorting', [0, 'asc']) // for default sorting column // here 0 means first column
        .withOption("paging", true)
        .withOption("pagingType", 'simple_numbers')
        .withOption("pageLength", 9)
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
        for (x in cols) {
            if (typeof cols[x].isSort == 'undefined')
                cols[x].isSort = true;
            if (cols[x].isSort == false)
                vm.dtColumns.push(DTColumnBuilder.newColumn(cols[x].name, cols[x].heading).withOption(cols[x].name, cols[x].heading).notSortable());
            else
                vm.dtColumns.push(DTColumnBuilder.newColumn(cols[x].name, cols[x].heading).withOption(cols[x].name, cols[x].heading));
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

    //-------------------------------------
    // bo comment neu up len server --------------------------------------------------------------------------
    //-------------------------------------

    //  console.log('$scope--------------------------------', $scope, gridService);

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

}
