﻿angular.module('indexApp')
.controller('ProductCtrl', function ($scope, $rootScope, coreService, authoritiesService, alertFactory, dialogs, $filter, $state, $timeout) {
    $rootScope.showModal = false;
    $scope.gridInfo = {
        gridID: 'productgrid',
        table: null,
        cols: [
             { name: 'ZOrder', heading: 'ZOrder', width: '0', isHidden: true },
              { name: 'ID', heading: 'ID', width: '0', isHidden: true },
              { name: 'LastUpdatedDateTime', heading: 'Ngày chỉnh sửa', width: '50px', className: 'text-center' },
              { name: 'Name', heading: 'Name', width: '50px', className: 'text-center' },
              { name: 'Address', heading: 'Địa chỉ', width: '100px', className: 'text-center' },
              { name: 'ManagerName', heading: 'Tên quản lý', width: '180px', className: 'text-center' },
              { name: 'ManagerMobilePhone', heading: 'SĐT quản lý', width: '200px', className: 'text-center' },
              { name: 'Struture', heading: 'Kết cấu', width: '80px', className: 'text-center' },
              { name: 'AreaDescription', heading: 'Diện tích trống', width: '35px', className: 'text-center' },
              { name: 'PriceDescription', heading: 'Giá', width: '115px', className: 'text-center' },
              { name: 'Action', heading: 'Thao tác', width: '35px', className: 'text-center', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-pencil-square-o', action: 'view' }] }
              //{ name: 'Action', heading: 'Thao tác', width: '35px', className: 'text-center', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-pencil-square-o', action: 'view' }, { classIcon: ' fa-bar-chart', action: 'chart' }] }
        ],
        data: [],
        sysViewID: 19,
        searchQuery: '',
        onActionClick: function (row, act) {
            //            console.log(row, act);
            // row la data cua dong do
            //act la hanh dong em muon thao tac, mo cai swich ra xu ly ?? vd dum 1 cai 
            //  $scope.gridInfo.tableInstance.search(query).draw(); $scope.gridInfo.tableInstance.row( tr ).data();

            //alert('xem console view:' + act)
            switch (act) {
                case 'view':
                    //                    console.log('row', row);
                    $state.transitionTo('editproduct', { productId: row.ID });
                    // day neu em nhan vieư em data cua view , hoac neu em can update thi row la object data em dung de show len man hinh, ok ko
                    //                    alert('xem console view:' + act);
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
    $scope.districtSelectList = null;
    $scope.wardSelectList = null;
    coreService.getListEx({ CityID: 2, Sys_ViewID: 18 }, function (data) {
        //console.log('District--ward', data);
        $scope.districtSelectList = data[1];
        $scope.wardSelectList = data[2];

        convertStringtoNumber($scope.districtSelectList, 'ID');
        convertStringtoNumber($scope.wardSelectList, 'DistrictID');
        convertStringtoNumber($scope.wardSelectList, 'ID');

        $scope.tempWardSelectList = angular.copy($scope.wardSelectList);
    });

    //coreService.getListEx({ ProductID: 1, Sys_ViewID: 19 }, function (data) {
    //    console.log('ProductID', data)
    //});
    $scope.$watch('productId', function (newVal, oldVal) {
        if (typeof newVal != 'undefined') {
            $rootScope.showModal = true;
            coreService.getListEx({ ProductID: $scope.productId, Sys_ViewID: 19 }, function (data) {
                console.log('ProductID', data);
                convertStringtoNumber(data[1], 'DistrictID');
                convertStringtoNumber(data[1], 'WardID');
                convertStringtoNumber(data[1], 'AreaPerFloor');
                convertStringtoBoolean(data[1], 'IsGroundFloor');
                convertStringtoBoolean(data[1], 'IsHiredWholeBuilding');

                $scope.dataSelected = data[1][0];
                $rootScope.showModal = false;
                $scope.$apply();

                //console.log('ProductID after', data[1]);
            });
        }
    })

    //var entry = { Name: 'thanh', WardID: 1, DistrictID: 1, Address: '537/7A Đường Tân Chánh Hiệp. P. Tân Chánh Hiệp. Q.12. TPHCM.' };
    //entry.Action = 'INSERT';
    //entry.Sys_ViewID = 19;
    //coreService.actionEntry2(entry, function (data) {
    //    console.log('InsertdataProduct', data)
    //});
    $scope.actionEntry = function (act) {
        if (typeof act != 'undefined') {
            var entry = angular.copy($scope.dataSelected);
            entry.UnAssignedName = tiengvietkhongdau(entry.Name); //coreService.toASCi(entry.Name);
            entry.UnAssignedAddress = tiengvietkhongdau(entry.Address); //coreService.toASCi(entry.Address);
            entry.Action = act;
            entry.Sys_ViewID = 19; //$scope.gridInfo.sysViewID;

            console.log('entry', entry);
            for (var property in entry) {
                if (entry.hasOwnProperty(property)) {
                    if (entry[property] == '') {
                        delete entry[property];
                    }
                }
            }

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
                            $state.go('productlist', '', { reload: true });
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

    $scope.searchEntry = {
        UnAssignedName: null,
        UnAssignedAddress: null,
        PriceFrom: null,
        PriceTo: null,
        DistrictID: null,
        WardID: null,
        Address: null,
        AvailableAreaFrom: null,
        AvailableAreaTo: null,
        PriceFrom: null,
        PriceTo: null,
        IsHiredWholeBuilding: null,
        IsGroundFloor: null,
        BuildingDirectionID: null,
        Status: null,
        Sys_ViewID: 20
    };

    $scope.search = function (searchEntry) {
        $rootScope.showModal = true;

        //var entry = {
        //    UnAssignedName: $scope.Name, //coreService.toASCi($scope.Name),
        //    UnAssignedAddress: $scope.Address, //coreService.toASCi($scope.Address),
        //    PriceFrom: $scope.PriceFrom,
        //    PriceTo: $scope.PriceTo,
        //    DistrictID: $scope.DistrictID,
        //    WardID: $scope.WardID,
        //    Address: $scope.Address,
        //    AvailableAreaFrom: $scope.AvailableAreaFrom,
        //    AvailableAreaTo: $scope.AvailableAreaTo,
        //    PriceFrom: $scope.PriceFrom,
        //    PriceTo: $scope.PriceTo,
        //    IsHiredWholeBuilding: $scope.IsHiredWholeBuilding,
        //    IsGroundFloor: $scope.IsGroundFloor,
        //    BuildingDirectionID: $scope.BuildingDirectionID,
        //    Status: $scope.Status,
        //    Sys_ViewID: 20
        //};

        for (var property in searchEntry) {
            if (searchEntry.hasOwnProperty(property)) {
                if (searchEntry[property] == '' || searchEntry[property] == false || searchEntry[property] == null) {
                    delete searchEntry[property];
                }
            }
        }
        searchEntry.UnAssignedName = tiengvietkhongdau(searchEntry.Name);
        searchEntry.UnAssignedAddress = tiengvietkhongdau(searchEntry.Address);

        if ($rootScope.searchEntryFilter != null)
            searchEntry = $rootScope.searchEntryFilter;
        else
            $rootScope.searchEntryFilter = searchEntry;

        coreService.getListEx(searchEntry, function (data) {
            // console.log('Search', data);
            $scope.gridInfo.data = data[1];
            $rootScope.showModal = false;
            $scope.$apply();

            //$rootScope.$broadcast('changeGridData', {
            //    gridData: data[1]
            //})
        });
    }

    if ($rootScope.searchEntryFilter != null && typeof $rootScope.searchEntryFilter != 'undefined') {
        $scope.searchEntry = $rootScope.searchEntryFilter;
        $scope.search($scope.searchEntry);
    }


    $scope.changeDistrict = function (districtID) {
        $scope.dataSelected.WardId = null;
        $scope.wardSelectList = $filter('filterDistrictID')($scope.tempWardSelectList, districtID);
    }

    function convertStringtoNumber(array, fieldName) {
        angular.forEach(array, function (item, key) {
            if (!isNaN(item[fieldName]) && item[fieldName] != '')
                item[fieldName] = parseInt(item[fieldName]);
        });
    }
    function convertStringtoBoolean(array, fieldName) {
        angular.forEach(array, function (item, key) {
            if (item[fieldName] === "True") {
                item[fieldName] = true;
            } else {
                item[fieldName] = false;
            }

        });
    }

    function tiengvietkhongdau(str) {

        if (str == null || typeof str == 'undefined' || str == '')
            return "";

        /* str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
         str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ.+/g, "e");
         str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
         str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ.+/g, "o");
         str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
         str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
         str = str.replace(/đ/g, "d");
         */
        str = locdau(str);
        str = str.replace(/-+-/g, "-"); //thay thế 2- thành 1-
        str = str.replace(/^\-+|\-+$/g, "");
        return str;
    }
    function locdau(slug) {
        //Đổi ký tự có dấu thành không dấu
        slug = slug.replace(/á|à|ả|ạ|ã|ă|ắ|ằ|ẳ|ẵ|ặ|â|ấ|ầ|ẩ|ẫ|ậ/gi, "a");
        slug = slug.replace(/é|è|ẻ|ẽ|ẹ|ê|ế|ề|ể|ễ|ệ/gi, "e");
        slug = slug.replace(/i|í|ì|ỉ|ĩ|ị/gi, "i");
        slug = slug.replace(/ó|ò|ỏ|õ|ọ|ô|ố|ồ|ổ|ỗ|ộ|ơ|ớ|ờ|ở|ỡ|ợ/gi, "o");
        slug = slug.replace(/ú|ù|ủ|ũ|ụ|ư|ứ|ừ|ử|ữ|ự/gi, "u");
        slug = slug.replace(/ý|ỳ|ỷ|ỹ|ỵ/gi, "y");
        slug = slug.replace(/đ/gi, "d");
        //Xóa các ký tự đặt biệt
        slug = slug.replace(/\`|\~|\!|\@|\#|\||\$|\%|\^|\&|\*|\(|\)|\+|\=|\,|\.|\/|\?|\>|\<|\"|\"|\:|\;|_/gi, "");
        //Đổi khoảng trắng thành ký tự gạch ngang
        slug = slug.replace(/ /gi, " ");
        //Đổi nhiều ký tự gạch ngang liên tiếp thành 1 ký tự gạch ngang
        //Phòng trường hợp người nhập vào quá nhiều ký tự trắng
        slug = slug.replace(/\-\-\-\-\-/gi, "-");
        slug = slug.replace(/\-\-\-\-/gi, "-");
        slug = slug.replace(/\-\-\-/gi, "-");
        slug = slug.replace(/\-\-/gi, "-");
        //Xóa các ký tự gạch ngang ở đầu và cuối
        slug = "@" + slug + "@";
        slug = slug.replace(/\@\-|\-\@|\@/gi, "");
        return slug;
    }


})