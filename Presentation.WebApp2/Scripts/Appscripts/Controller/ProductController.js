angular.module('indexApp')
.controller('ProductCtrl', function ($scope, coreService, authoritiesService, alertFactory, dialogs, $filter) {
    $scope.gridInfo = {
        gridID: 'productgrid',
        table: null,
        cols: [
              { name: 'ID', heading: 'ID', width: '0', isHidden: true },
              { name: 'LastUpdatedDatetime', heading: 'Ngày chỉnh sửa', width: '5%' },
              { name: 'Name', heading: 'Name', width: '10%' },
              { name: 'Address', heading: 'Địa chỉ', width: '10%' },
              { name: 'Owner', heading: 'Tên quản lý', width: '5%' },
              { name: 'OwnerPhoneNumber', heading: 'SĐT quản lý', width: '5%' },
              { name: 'Structure', heading: 'Kết cấu', width: '20%' },
              { name: 'AvailableArea', heading: 'Diện tích trống', width: '10%' },
              { name: 'Price', heading: 'Giá', width: '5%' },
              { name: 'Action', heading: 'Thao tác', width: '3%', className: 'text-center', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-pencil-square-o', action: 'view' }, { classIcon: ' fa-bar-chart', action: 'chart' }] }
        ],
        data: [],
        sysViewID: 11,
        searchQuery: '',
        onActionClick: function (row, act) {
            console.log(row, act);
            // row la data cua dong do
            //act la hanh dong em muon thao tac, mo cai swich ra xu ly ?? vd dum 1 cai 
            //  $scope.gridInfo.tableInstance.search(query).draw(); $scope.gridInfo.tableInstance.row( tr ).data();

            alert('xem console view:' + act)
            switch (act) {
                case 'view':
                    console.log();
                    // day neu em nhan vieư em data cua view , hoac neu em can update thi row la object data em dung de show len man hinh, ok ko
                    alert('xem console view:' + act);
                    //coreService.getListEx({ ProductID: row.ID, Sys_ViewID: 19 }, function (data) {
                    //    console.log('ProductID', data)
                    //});
                    break;
                case 'chart':
                    $scope.openDialogChart(rowID);

                    break;


            }
        }
    }

    $scope.listRight = authoritiesService.get($scope.gridInfo.sysViewID);

    $scope.statusOptions = statusOptions;
    $scope.layout = {
        enableClear: false,
        enableButtonOrther: false
    }
    $scope.dataSelected = { ID: 0, Name: "", Code: '', Description: "", Status: "0", Sys_ViewID: $scope.gridInfo.sysViewID };
    $scope.init = function () {
        window.setTimeout(function () {
            $(window).trigger("resize")
        }, 200);
    }
    $scope.setData = function (data) {
        if (typeof data != 'undefined') {
            $scope.dataSelected = data;
            $scope.layout.enableClear = true;
            $scope.layout.enableButtonOrther = true;
        }
    }
    $scope.actionConfirm = function (act) {
        var dlg = dialogs.confirm('Confirmation', 'Confirmation required');
        dlg.result.then(function (btn) {
            $scope.actionEntry(act);
        }, function (btn) {
            //$scope.confirmed = 'You confirmed "No."';
        });
    }

    $scope.reset = function (data) {
        $scope.dataSelected = { ID: 0, Name: '', Code: '', Description: "", Status: "0", Sys_ViewID: $scope.gridInfo.sysViewID };
        $scope.layout = {
            enableClear: false,
            enableButtonOrther: false
        }
        // $scope.$apply();
    }

    $scope.searchTable = function () {
        var query = $scope.gridInfo.searchQuery;
        $scope.gridInfo.tableInstance.search(query).draw();
    };
    $scope.changeText = function () {
        if ($scope.dataSelected.Name == '')
            $scope.layout.enableClear = false;
        else
            $scope.layout.enableClear = true;

        if ($scope.dataSelected.Name == '')
            $scope.layout.enableButtonOrther = false;
        else
            $scope.layout.enableButtonOrther = true;

        // $scope.$apply();
    }

    $scope.launch = function (which) {
        switch (which) {
            case 'error':
                dialogs.error();
                break;
            case 'wait':
                var dlg = dialogs.wait(undefined, undefined, _progress);
                _fakeWaitProgress();
                break;
            case 'customwait':
                var dlg = dialogs.wait('Custom Wait Header', 'Custom Wait Message', _progress);
                _fakeWaitProgress();
                break;
            case 'notify':
                dialogs.notify();
                break;
            case 'confirm':
                var dlg = dialogs.confirm();
                dlg.result.then(function (btn) {
                    $scope.confirmed = 'You confirmed "Yes."';
                }, function (btn) {
                    $scope.confirmed = 'You confirmed "No."';
                });
                break;
            case 'custom':
                var dlg = dialogs.create('/dialogs/custom.html', 'customDialogCtrl', {}, { size: 'lg', keyboard: true, backdrop: false, windowClass: 'my-class' });
                dlg.result.then(function (name) {
                    $scope.name = name;
                }, function () {
                    if (angular.equals($scope.name, ''))
                        $scope.name = 'You did not enter in your name!';
                });
                break;
            case 'custom2':
                var dlg = dialogs.create('/dialogs/custom2.html', 'customDialogCtrl2', $scope.custom, { size: 'lg' });
                break;
        }
    }// end launch
    // $scope.launch('error');

    //phu viet cho nay
    coreService.getListEx({ Code: "BUILDINGDIRECTION", Sys_ViewID: 17 }, function (data) {
        //        console.log('BUILDINGDIRECTION', data);
        $scope.buildingDirectionIDSelectList = data[1];
    });
    //phu viet cho nay
    coreService.getListEx({ CityID: 2, Sys_ViewID: 18 }, function (data) {
        //console.log('District--ward', data);
        $scope.districtSelectList = data[1];
        $scope.wardSelectList = data[2];
        $scope.tempWardSelectList = angular.copy($scope.wardSelectList);


        convertStringtoNumber($scope.districtSelectList, 'ID');
        convertStringtoNumber($scope.wardSelectList, 'DistrictID');
        convertStringtoNumber($scope.tempWardSelectList, 'DistrictID');
    });

    //coreService.getListEx({ ProductID: 1, Sys_ViewID: 19 }, function (data) {
    //    console.log('ProductID', data)
    //});

    //var entry = { Name: 'thanh', WardID: 1, DistrictID: 1, Address: '537/7A Đường Tân Chánh Hiệp. P. Tân Chánh Hiệp. Q.12. TPHCM.' };
    //entry.Action = 'INSERT';
    //entry.Sys_ViewID = 19;
    //coreService.actionEntry2(entry, function (data) {
    //    console.log('InsertdataProduct', data)
    //});
    $scope.actionEntry = function (act) {
        if (typeof act != 'undefined') {
            var entry = angular.copy($scope.dataSelected);
            entry.Action = act;
            entry.Sys_ViewID = 19; //$scope.gridInfo.sysViewID;
            coreService.actionEntry2(entry, function (data) {
                if (data.Success) {
                    switch (act) {
                        case 'INSERT':
                            entry.ID = data.Result;
                            $scope.gridInfo.data.unshift(entry);
                            break;
                        case 'UPDATE':
                            angular.forEach($scope.gridInfo.data, function (item, key) {
                                if (entry.ID == item.ID) {
                                    $scope.gridInfo.data[key] = angular.copy(entry);

                                }
                            });
                            break;
                        case 'DELETE':
                            var index = -1;
                            var i = 0;
                            angular.forEach($scope.gridInfo.data, function (item, key) {
                                if (entry.ID == item.ID)
                                    index = i;
                                i++;
                            });
                            if (index > -1)
                                $scope.gridInfo.data.splice(index, 1);
                            break;
                    }
                    $scope.reset();

                }
                dialogs.notify(data.Message.Name, data.Message.Description);
                $scope.$apply();

            });
        }
    }

    $scope.changeDistrict = function () {
        $scope.dataSelected.WardId = null;
        $scope.wardSelectList = $filter('filterDistrictID')($scope.tempWardSelectList, $scope.dataSelected.DistrictID);
    }

    function convertStringtoNumber(array, fieldName) {
        angular.forEach(array, function (item, key) {
            item[fieldName] = parseInt(item[fieldName]);
        });
    }

})