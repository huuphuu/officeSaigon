angular.module('indexApp')
.controller('dataGridCtrl', dataGridsCtrl)
function dataGridsCtrl(DTOptionsBuilder, DTColumnDefBuilder, DTColumnDefBuilder, $scope, coreService) {
    //  console.log('$scope--------------------------------', $scope, gridService);
    var vm = this;
    vm.gridData = [];

    vm.dtOptions = DTOptionsBuilder.newOptions()
         .withOption("paging", true)
         .withOption("pagingType", 'simple_numbers')
         .withOption("pageLength", 9)
         .withOption("searching", true)
        .withOption("autowidth", false);
    //  .withLanguageSource('Scripts/plugins/datatables/LanguageSource.json');


    vm.init = function (gridInfo, rootScope) {
        vm.gridInfo = gridInfo;
        vm.rootScope = rootScope;
        coreService.getList($scope.gridInfo.sysViewID, function (data) {
            vm.gridInfo.data = angular.copy(data[1]);

            //them vao de test
//            if ($scope.gridInfo.sysViewID == 11) {
//                vm.gridInfo.data = [
//                    {
//                        "ID": 1,
//                        "LastUpdatedDatetime": "2016-01-26 15:48:43.153",
//                        "Name": "264 trường sa",
//                        "Address": "264 trường sa",
//                        "Owner": "Anh Nam",
//                        "OwnerPhoneNumber": "0996614884",
//                        "Structure": "12m2 15m2 18m2",
//                        "AvailableArea": 4000,
//                        "Price": "14$, 18(trệt a,b)"
//                    },
//                    {
//                        "ID": 2,
//                        "LastUpdatedDatetime": "2016-01-26 15:48:43.153",
//                        "Name": "264 trường sa",
//                        "Address": "264 trường sa",
//                        "Owner": "Anh Nam",
//                        "OwnerPhoneNumber": "0996614884",
//                        "Structure": "12m2 15m2 18m2",
//                        "AvailableArea": 4000,
//                        "Price": "14$, 18(trệt a,b)"
//                    },
//                    {
//                        "ID": 3,
//                        "LastUpdatedDatetime": "2016-01-26 15:48:43.153",
//                        "Name": "264 trường sa",
//                        "Address": "264 trường sa",
//                        "Owner": "Anh Nam",
//                        "OwnerPhoneNumber": "0996614884",
//                        "Structure": "12m2 15m2 18m2",
//                        "AvailableArea": 4000,
//                        "Price": "14$, 18(trệt a,b)"
//                    },
//                    {
//                        "ID": 4,
//                        "LastUpdatedDatetime": "2016-01-26 15:48:43.153",
//                        "Name": "264 trường sa",
//                        "Address": "264 trường sa",
//                        "Owner": "Anh Nam",
//                        "OwnerPhoneNumber": "0996614884",
//                        "Structure": "12m2 15m2 18m2",
//                        "AvailableArea": 4000,
//                        "Price": "14$, 18(trệt a,b)"
//                    },
//                    {
//                        "ID": 5,
//                        "LastUpdatedDatetime": "2016-01-26 15:48:43.153",
//                        "Name": "264 trường sa",
//                        "Address": "264 trường sa",
//                        "Owner": "Anh Nam",
//                        "OwnerPhoneNumber": "0996614884",
//                        "Structure": "12m2 15m2 18m2",
//                        "AvailableArea": 4000,
//                        "Price": "14$, 18(trệt a,b)"
//                    }
//                ];
//            }
            //end thme vao de test

            $scope.$apply();

        });

        angular.forEach($scope.gridInfo.cols, function (value, key) {
            if (typeof value != "function" && typeof value != "object") {
                // value = html.decode(value);
                inputs.push($.string.Format('{0}="{1}" ', key, objThis.html.encode(value)));
            }
        });
        vm.dtColumnDefs = [];
        var x, k = 0, cols = $scope.gridInfo.cols, arr = new Array();
        for (x in cols) {
            if (typeof cols[x].isSort == 'undefined')
                cols[x].isSort = true;
            if (cols[x].isSort == false)
                vm.dtColumnDefs.push(DTColumnDefBuilder.newColumnDef(k++).notSortable());
            else
                vm.dtColumnDefs.push(DTColumnDefBuilder.newColumnDef(k++));
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
