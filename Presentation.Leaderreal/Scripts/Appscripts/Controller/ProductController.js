﻿angular.module('indexApp')
.controller('ProductCtrl', function ($scope, $rootScope, coreService, authoritiesService, alertFactory, dialogs, $filter, $state, $timeout, modalUtils, productService, exportExcelService, localStorageService) {
    $rootScope.showModal = false;
    $rootScope.exportInfo = localStorageService.get('authorizationData');
    $rootScope.searchEntryFilter = null;
    $rootScope.selectedItems = null;

    var titleHtml = '<input type="checkbox" ng-model="vm.selectAll" ng-click="vm.toggleAll(vm.selectAll, vm.selected)">';
    $scope.gridInfo = {
        gridID: 'productgrid',
        table: null,
        cols: [
            { name: 'RowIndex', heading: 'RowIndex', isHidden: true },
            { name: 'ID', heading: 'ID', isHidden: true },
            { name: 'MultiSelect', heading: titleHtml, width: '50px', className: 'text-center pd-0 break-word', type: controls.CHECKBOX, listAction: [{ classIcon: 'form-control', action: 'multiSelect' }] },
            { name: 'LastUpdatedDateTime', heading: 'Ngày chỉnh sửa', width: '90px', className: 'text-center pd-0 break-word' },
            { name: 'Name', heading: 'Tên', className: 'text-center pd-0 break-word' },
              { name: 'HomeNumber', heading: 'Số nhà', width: '50px', className: 'text-center pd-0 break-word' },
            { name: 'Address', heading: 'Địa chỉ', className: 'text-center pd-0 break-word' },
            { name: 'ManagerName', heading: 'Tên quản lý', className: 'text-center pd-0 break-word' },
            { name: 'ManagerMobilePhone', heading: 'SĐT quản lý', className: 'text-center pd-0 break-word' },
            { name: 'Struture', heading: 'Kết cấu', className: 'text-center pd-0 break-word' },
            { name: 'AreaDescription', heading: 'Diện tích trống', width: '150px', className: 'text-center pd-0 break-word' },
            { name: 'PriceDescription', heading: 'Giá', className: 'text-center pd-0 break-word' },
            { name: 'Action1', heading: 'Sửa', width: '50px', className: 'text-center pd-0 break-word', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-pencil-square-o', action: 'view' }] },
            { name: 'Action2', heading: 'Xóa', width: '50px', className: 'text-center pd-0 break-word', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-times', action: 'delete' }] }
        ],
        data: [],
        sysViewID: 20,
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
                    //                    $state.transitionTo('editproduct', { productId: row.ID || row });
                    $scope.productId = row.ID || row;
                    productService.ProductID = row.ID || row;
                    if (modalUtils.modalsExist())
                        modalUtils.closeAllModals();
                    $scope.openDialog('view');
                    break;
                case 'delete':
                    console.log('row', row);
                    if (modalUtils.modalsExist())
                        modalUtils.closeAllModals();
                    var dlg = dialogs.confirm('Confirmation', 'Confirmation required');
                    dlg.result.then(function (btn) {
                        $scope.deleteId = row.ID || row;
                        $scope.actionEntry('DELETE');
                    }, function (btn) {
                        //                        console.log('no');
                    });


                    break;

                case 'multiSelect':
                    console.log();
                    break;

                case 'chart':
                    $scope.openDialogChart(rowID);


                    break;


            }
        }
    }

    $scope.productAreaPattern = /^(?:[0-9 ]+$)/;
    $scope.productPricePattern = /^(?:[0-9 \.]+$)/;

    coreService.getList(10, function (data) {
        authoritiesService.set(data[1]);
        $scope.listRight = authoritiesService.get($scope.gridInfo.sysViewID);
        $scope.$apply();
        if (typeof $scope.gridInfo.dtInstance == 'undefined') {
            $timeout(function () {
                if ($scope.listRight && $scope.listRight.IsUpdate && $scope.listRight.IsUpdate == 'False') {
                    console.log('$scope.listRight', $scope.listRight);
                    $scope.gridInfo.dtInstance.DataTable.column(12).visible(false);
                }
                if ($scope.listRight && $scope.listRight.IsDelete && $scope.listRight.IsDelete == 'False') {
                    console.log('$scope.listRight', $scope.listRight);
                    $scope.gridInfo.dtInstance.DataTable.column(13).visible(false);
                }
            }, 100)
        } else {
            if ($scope.listRight && $scope.listRight.IsUpdate && $scope.listRight.IsUpdate == 'False') {
                $scope.gridInfo.dtInstance.DataTable.column(12).visible(false);
                if ($scope.listRight && $scope.listRight.IsDelete && $scope.listRight.IsDelete == 'False')
                    $scope.gridInfo.dtInstance.DataTable.column(13).visible(false);
            }
        }

    });


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
        $scope.actionEntry(act);
        //var dlg = dialogs.confirm('Confirmation', 'Confirmation required');
        //dlg.result.then(function (btn) {
        //    $scope.actionEntry(act);
        //}, function (btn) {
        //    //$scope.confirmed = 'You confirmed "No."';
        //});
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
            //                $rootScope.showModal = true;
            //                coreService.getListEx({ ProductID: $scope.productId, Sys_ViewID: 19 }, function (data) {
            //                    console.log('ProductID', data);
            //                    convertStringtoNumber(data[1], 'DistrictID');
            //                    convertStringtoNumber(data[1], 'WardID');
            //                    convertStringtoNumber(data[1], 'AreaPerFloor');
            //                    convertStringtoBoolean(data[1], 'IsGroundFloor');
            //                    convertStringtoBoolean(data[1], 'IsHiredWholeBuilding');
            //    
            //                    $scope.dataSelected = data[1][0];
            //                    $rootScope.showModal = false;
            //                    $scope.$apply();
            //                    //console.log('ProductID after', data[1]);
            //                });
            productService.broadcastProductData();
        }
    })

    $scope.openDialog = function (act) {
        console.log('openDialog');
        var dlg = dialogs.create('/templates/view/product/product-popup.html', 'productDialogCtrl', productService, { size: 'lg', keyboard: false, backdrop: false });
        dlg.result.then(function (refreshList) {
            //            console.log('dialogs', refreshList);
            if (refreshList) {
                if (typeof $scope.gridInfo.dtInstance == 'undefined') {
                    $timeout(function () {
                        $scope.gridInfo.dtInstance.reloadData();
                    }, 1000);
                } else {
                    $scope.gridInfo.dtInstance.reloadData();
                }
            }

        }, function () {
            if (angular.equals($scope.name, ''))
                $scope.name = 'You did not enter in your name!';
        });
    }

    //var entry = { Name: 'thanh', WardID: 1, DistrictID: 1, Address: '537/7A Đường Tân Chánh Hiệp. P. Tân Chánh Hiệp. Q.12. TPHCM.' };
    //entry.Action = 'INSERT';
    //entry.Sys_ViewID = 19;
    //coreService.actionEntry2(entry, function (data) {
    //    console.log('InsertdataProduct', data)
    //});
    $scope.actionEntry = function (act) {
        $scope.clicked = true;
        if (typeof act != 'undefined') {
            var entry = angular.copy($scope.dataSelected);
            entry.UnAssignedName = tiengvietkhongdau(entry.Name); //coreService.toASCi(entry.Name);
            entry.UnAssignedAddress = tiengvietkhongdau(entry.Address); //coreService.toASCi(entry.Address);
            entry.Action = act;
            entry.Sys_ViewID = 19; //$scope.gridInfo.sysViewID;
            entry.Description = entry.Description.replace(/\n\r?/g, '<br />');

            //            console.log('entry', entry);
            for (var property in entry) {
                if (entry.hasOwnProperty(property)) {
                    if (entry[property] == '') {
                        delete entry[property];
                    }
                }
            }
            if (act == 'DELETE')
                entry.ID = $scope.deleteId;

            coreService.actionEntry2(entry, function (data) {
                if (data.Success) {
                    switch (act) {
                        case 'INSERT':
                            entry.ID = data.Result;
                            $scope.gridInfo.data.unshift(entry);
                            dialogs.notify(data.Message.Name, data.Message.Description);
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

                            dialogs.notify(data.Message.Name, data.Message.Description);

                            if (typeof $scope.gridInfo.dtInstance == 'undefined') {
                                $timeout(function () {
                                    $scope.gridInfo.dtInstance.reloadData();
                                }, 1000);
                            } else {
                                $scope.gridInfo.dtInstance.reloadData();
                            }
                            break;
                    }
                    $scope.reset();

                }
                //thong bao ket qua
                //dialogs.notify(data.Message.Name, data.Message.Description);
                $scope.clicked = false;
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
        Sys_ViewID: 20,
        Status: "0"
    };

    $scope.search = function (searchEntry) {
        // $rootScope.showModal = true;

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


        if (typeof $scope.gridInfo.dtInstance == 'undefined') {
            $timeout(function () {
                $scope.gridInfo.dtInstance.reloadData();
            }, 1000);
        } else {
            $scope.gridInfo.dtInstance.reloadData();
        }


        //coreService.getListEx(searchEntry, function (data) {
        //    // console.log('Search', data);
        //    $scope.gridInfo.data = data[1];
        //    $rootScope.showModal = false;
        //    $scope.$apply();

        //    //$rootScope.$broadcast('changeGridData', {
        //    //    gridData: data[1]
        //    //})
        //});
    }

    if ($rootScope.searchEntryFilter != null && typeof $rootScope.searchEntryFilter != 'undefined' && $state.current.url == '/product-list') {
        $scope.searchEntry = $rootScope.searchEntryFilter;
        //        console.log('$scope.searchEntry', $scope.searchEntry);
        $scope.search($scope.searchEntry);

    }


    $scope.exportExcels = function () {
        var selectedId = [];
//        var selectedItems = $rootScope.selectedItems;
        var selectedItems = $rootScope.hasSelectedItems;
        for (var id in selectedItems) {
            if (selectedItems.hasOwnProperty(id)) {
                if (selectedItems[id]) {
                    selectedId.push(id);
                }
            }
        }

        $rootScope.selectedExportIDs = selectedId;

        //mo popup
        var dlg = dialogs.create('/templates/view/product/export-popup.html', 'exportDialogCtrl', exportExcelService, { size: 'lg', keyboard: false, backdrop: false });
        dlg.result.then(function (val) {
            //            console.log('dialogs', val);
            if (val) {

            }

        }, function () {

        });

        //        var hiddenIframeId = "#hiddenDownloader";
        //        coreApp.CallFunctionFromiFrame(hiddenIframeId, "RunExport", selectedId.toString(), function () { }, 100);
        //        //   thisObj._win.RunExport(_data);

        console.log('selectedId', selectedId.toString());
    };

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

.controller('productDialogCtrl', function ($scope, $rootScope, $modalInstance, productService, $timeout, coreService, dialogs, $filter) {
    $rootScope.showModal = true;
    $scope.productAreaPattern = /^(?:[0-9 ]+$)/;
    $scope.productPricePattern = /^(?:[0-9 \.]+$)/;

    $timeout(function () {
        $scope.dataSelected = productService.dataSelected;
        console.log('$scope.dataSelected', $scope.dataSelected);
        $scope.dataSelected.Description && ($scope.dataSelected.Description = $scope.dataSelected.Description.replace(/<br \/>/g, '\n'));
        $rootScope.showModal = false;
    }, 2000);

    $scope.title = 'Chỉnh sửa sản phẩm';
    $scope.refreshList = false;

    $scope.cancel = function () {
        $modalInstance.dismiss('Canceled');
    }; // end cancel

    $scope.save = function () {
        var act = "UPDATE";
        //console.log("save:data", $scope.dataSelected);
        //console.log("save:projectService", projectService.dataSelected);
        if ($scope.dataSelected.ID != undefined && $scope.dataSelected.ID > 0) act = "UPDATE";
        $scope.actionConfirm(act);
    }; // end save

    $scope.actionConfirm = function (act) {
        $scope.actionEntry(act);
        //var dlg = dialogs.confirm('Confirmation', 'Confirmation required');
        //dlg.result.then(function (btn) {
        //    $scope.actionEntry(act);
        //}, function (btn) {
        //    //$scope.confirmed = 'You confirmed "No."';
        //});
    }

    $scope.actionEntry = function (act) {
        $scope.clicked = true;
        if (typeof act != 'undefined') {
            var entry = angular.copy($scope.dataSelected);
            entry.UnAssignedName = tiengvietkhongdau(entry.Name); //coreService.toASCi(entry.Name);
            entry.UnAssignedAddress = tiengvietkhongdau(entry.Address); //coreService.toASCi(entry.Address);
            entry.Action = act;
            entry.Sys_ViewID = 19; //$scope.gridInfo.sysViewID;
            entry.Description && (entry.Description = entry.Description.replace(/\n\r?/g, '<br />'));
            //            console.log('entry', entry);

            for (var property in entry) {
                if (entry.hasOwnProperty(property)) {
                    if (entry[property] == '') {
                        delete entry[property];
                    }
                }
            }
            if (act == 'DELETE')
                entry.ID = $scope.deleteId;

            coreService.actionEntry2(entry, function (data) {
                if (data.Success) {
                    switch (act) {
                        case 'INSERT':
                            //                            entry.ID = data.Result;
                            //                            $scope.gridInfo.data.unshift(entry);
                            //                            dialogs.notify(data.Message.Name, data.Message.Description);
                            break;
                        case 'UPDATE':
                            $modalInstance.close($scope.refreshList);
                            break;
                        case 'DELETE':
                            //                            var index = -1;
                            //                            var i = 0;
                            //                            angular.forEach($scope.gridInfo.data, function (item, key) {
                            //                                if (entry.ID == item.ID)
                            //                                    index = i;
                            //                                i++;
                            //                            });
                            //                            if (index > -1)
                            //                                $scope.gridInfo.data.splice(index, 1);
                            //
                            //                            dialogs.notify(data.Message.Name, data.Message.Description);
                            //
                            //                            if (typeof $scope.gridInfo.dtInstance == 'undefined') {
                            //                                $timeout(function () {
                            //                                    $scope.gridInfo.dtInstance.reloadData();
                            //                                }, 1000);
                            //                            } else {
                            //                                $scope.gridInfo.dtInstance.reloadData();
                            //                            }
                            break;
                    }
                    //                    $scope.reset();

                }
                //thong bao ket qua
                //dialogs.notify(data.Message.Name, data.Message.Description);
                $scope.clicked = false;
                $scope.$apply();

            });
        }
    }

    $scope.statusOptions = statusOptions;
    $scope.layout = {
        enableClear: false,
        enableButtonOrther: false
    }

    coreService.getListEx({ Code: "BUILDINGDIRECTION", Sys_ViewID: 17 }, function (data) {
        $scope.buildingDirectionIDSelectList = data[1];
    });

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

.controller('exportDialogCtrl', function ($scope, $rootScope, $modalInstance, exportExcelService, $timeout, coreService, dialogs, $filter) {
    //    $rootScope.showModal = true;

    $scope.title = 'Điền thông tin xuất file';
    $scope.data = $rootScope.exportInfo;
    $scope.data.viewId = 26;
    $scope.data.fileType = 'excel';
    console.log($scope.data);
    $scope.cancel = function () {
        $modalInstance.dismiss('Canceled');
    }; // end cancel


    $scope.exportExcel = function (data) {
        var exportIDs = $rootScope.selectedExportIDs;
        console.log('data export', data, exportIDs);


        var selectedId = [];
        var selectedItems = $rootScope.hasSelectedItems;// $rootScope.selectedItems;
        for (var id in selectedItems) {
            if (selectedItems.hasOwnProperty(id)) {
                if (selectedItems[id]) {
                    selectedId.push(id);
                }
            }
        }

        var languageId = "129";//"Excel|Pdf
        var hiddenIframeId = "#hiddenDownloader";
        var exportData = {
            listId: selectedId.toString(), 
            exportType: data.fileType, 
            sysViewId: data.viewId, 
            languageId: languageId,
            addressTo: data.addressTo,
            fullName: data.FullName,
            telePhone: data.TelePhone,
            cellPhone: data.CellPhone,
            email: data.Email,
            position: data.Position,
            fileName: data.FileName
        };
        console.log('exportData', exportData);
        coreApp.CallFunctionFromiFrame(hiddenIframeId, "RunExport", exportData, function () { }, 100);
        //  $('#infoExportModal').modal('hide');


        $rootScope.hasSelectedItems = {};
        //tat popup 
        $modalInstance.close('Success');
    }
})