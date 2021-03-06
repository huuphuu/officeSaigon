﻿angular.module('indexApp')
.controller('CustomerCtrl', function ($scope, $rootScope, coreService, authoritiesService, alertFactory, dialogs, $filter, $state, $timeout, modalUtils, customerService, localStorageService) {
    $rootScope.showModal = false;

    $scope.UserInfo = localStorageService.get('authorizationData');
    if ($scope.UserInfo.UserGroupID != null)
        $scope.UserInfo.UserGroupID = parseInt($scope.UserInfo.UserGroupID);
    //  console.log(' $scope.UserInfo.UserGroupID', $scope.UserInfo.UserGroupID)

    $scope.statusOptions = statusOptions;
    $scope.potentialOptions = potentialOptions;
    $scope.customerTypeOptions = customerTypeOptions;
    $scope.contractStatus = contractStatus;
    $rootScope.searchEntryFilter = null;
    $rootScope.selectedItems = null;

    $scope.layout = {
        enableClear: false,
        enableButtonOrther: false
    }

    $scope.searchEntry = {
        UnAssignedName: null,
        Phone: null,
        Email: null,
        Potential: null,
        Status: "0",
        Type: null,
        AssignUserId: null,
        Assign: $scope.customerTypeOptions[0].value,
        Sys_ViewID: 21
    };

    $scope.gridInfo = {
        gridID: 'customergrid',
        table: null,
        //cols: $scope.searchEntry.Assign == '0' ? gridCols1 : gridCols2,
        cols: [
             { name: 'RowIndex', heading: 'RowIndex', isHidden: true },
              { name: 'ID', heading: 'ID', isHidden: true },
              //{ name: 'MultiSelect', heading: '', isHidden: true, className: 'text-center', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-pencil-square-o', action: 'view' }] },
              { name: 'LastUpdatedDateTime', heading: 'Ngày nhận khách', width: '90px', className: 'text-center pd-0 break-word' },
              { name: 'Name', heading: 'Tên', width: '90px', className: 'text-center pd-0 break-word' },
              { name: 'Phone', heading: 'Phone', width: '100px', className: 'text-center pd-0 break-word' },
              { name: 'Email', heading: 'Email', className: 'text-center pd-0 break-word' },
              { name: 'Request', heading: 'Yêu cầu', width: '220px', fixedHeight: true, className: 'text-center pd-0 break-word height-150' },
              { name: 'CareNote', heading: 'Quá trình chăm sóc', width: '250px', fixedHeight: true, className: 'text-left pd-0 break-word height-150', isHidden: $scope.UserInfo.UserGroupID == 0 ? false : true },
              { name: 'Action1', heading: 'Sửa', width: '50px', className: 'text-center pd-0 break-word', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-pencil-square-o', action: 'view' }] },
              { name: 'Action2', heading: 'Xóa', width: '50px', className: 'text-center pd-0 break-word', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa-times', action: 'delete' }] },

        ],
        data: [],
        sysViewID: 21,
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
                    var currentUserInfo = localStorageService.get('authorizationData'),
                        currentUserID = currentUserInfo.ID;
                    $scope.currentUserID = currentUserID;

                    //  if ($scope.searchEntry.Assign != '1' && (currentUserID != 13 && currentUserID != 18)) {
                    if ($scope.UserInfo.UserGroupID < 1) {
                        $scope.customerId = row.ID || row;
                        customerService.CustomerID = $scope.customerId;
                        if (modalUtils.modalsExist())
                            modalUtils.closeAllModals();
                        $scope.openDialog('view');
                    } else {
                        $state.transitionTo('editcustomer', { customerId: row.ID || row });
                        //                        console.log('row.ID || row', row.ID, row);
                    }
                    break;

                    //                case 'AssignView':
                    //                    $scope.customerId = row.ID || row;
                    //                    customerService.CustomerId = row.ID || row;
                    //                    if (modalUtils.modalsExist())
                    //                        modalUtils.closeAllModals();
                    //                    $scope.openDialog('view');
                    //                    break;

                case 'delete':
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
                case 'assign':
                    $scope.customerId = row.ID || row;
                    customerService.CustomerID = $scope.customerId;
                    if (modalUtils.modalsExist())
                        modalUtils.closeAllModals();
                    $scope.openDialog('assign');
                    break;



            }
        }
    }
    if ($scope.UserInfo.UserGroupID > 0) {
        $scope.gridInfo.cols.push({ name: 'Action3', heading: 'Assign', width: '50px', className: 'text-center pd-0 break-word', type: controls.LIST_ICON, listAction: [{ classIcon: 'fa fa-exchange', action: 'assign' }] });
    }

    coreService.getList(10, function (data) {
        authoritiesService.set(data[1]);
        $scope.listRight = authoritiesService.get($scope.gridInfo.sysViewID);
        //        console.log('$scope.listRight ', $scope.listRight);
        $scope.$apply();
        if (typeof $scope.gridInfo.dtInstance == 'undefined') {
            $timeout(function () {
                if ($scope.listRight && $scope.listRight.IsDelete && $scope.listRight.IsDelete == 'False')
                    if (typeof $scope.gridInfo.dtInstance != 'undefined') {
                        $scope.gridInfo.dtInstance.DataTable.column(9).visible(false);
                    }
            }, 500)
        } else {
            if ($scope.listRight && $scope.listRight.IsDelete && $scope.listRight.IsDelete == 'False') {
                $scope.gridInfo.dtInstance.DataTable.column(9).visible(false);
            }
        }

    });

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

    //get assignUser
    coreService.getList(7, function (data) {
        $scope.userList = data[1];
        $scope.$apply();
    });

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
    coreService.getListEx({ Code: "BUILDINGDIRECTION", Sys_ViewID: 22 }, function (data) {
        //        console.log('BUILDINGDIRECTION', data);
        $scope.assignIDSelectList = data[1];
    });

    //coreService.getListEx({ ProductID: 1, Sys_ViewID: 19 }, function (data) {
    //    console.log('ProductID', data)
    //});
    $scope.listAssign = []
    $scope.$watch('customerId', function (newVal, oldVal) {
        if (typeof newVal != 'undefined') {
            var currentUserInfo = localStorageService.get('authorizationData'),
                        currentUserID = currentUserInfo.ID;

            //            if (currentUserID == 13 || currentUserID == 18) {
            if ($scope.UserInfo.UserGroupID >= 1) {
                $rootScope.showModal = true;
                coreService.getListEx({ CustomerID: $scope.customerId, Sys_ViewID: 21 }, function (data) {
                    //convertStringtoNumber(data[1], 'DistrictID');
                    convertStringtoBoolean(data[1], 'Potential');
                    convertStringtoBoolean(data[1], 'IsSaleDeparment');

                    $scope.dataSelected = data[1][0];
                    $scope.dataSelected && $scope.dataSelected.Request && ($scope.dataSelected.Request = $scope.dataSelected.Request.replace(/<br \/>/g, '\n'));
                    $scope.dataSelected && $scope.dataSelected.CareNote && ($scope.dataSelected.CareNote = $scope.dataSelected.CareNote.replace(/<br \/>/g, '\n'));

                    $rootScope.showModal = false;

                    $scope.dataSelected = data[1][0];

                   var listAssign = new Array();
                    angular.forEach(data[3], function (item, key) {
                        if (item.Cheked == "1") {
                            listAssign.push(item);
                        }
                    });
                    console.log('$scope.listAssign', listAssign);
                    $scope.listAssign = listAssign;
                    $scope.changeCareNote();
                    $scope.$apply();
                    //console.log('CustomerID after', data[1]);
                });
            } else {
                customerService.broadcastCustomerData();
            }
        }
    })

    $scope.changeCareNote = function () {
        angular.forEach($scope.listAssign, function (item, key) {
            if (item.ID == $scope.dataSelected.AssignID) {
                $scope.dataSelected.CareNote = item.CareNote.replace(/<br \/>/g, '\n');
            }
        });
    }
    $scope.openDialog = function (act) {
        customerService.act = act;
        var dlg = null;
        if (act == 'assign')
            dlg = dialogs.create('/templates/view/customer/customer-popup-assign.html', 'customerDialogCtrl', customerService, { size: 'lg', keyboard: false, backdrop: false });
        else
            dlg = dialogs.create('/templates/view/customer/customer-popup.html', 'customerDialogCtrl', customerService, { size: 'lg', keyboard: false, backdrop: false });
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
            entry.Action = act;
            entry.Sys_ViewID = 21; //$scope.gridInfo.sysViewID;
            entry.Request && (entry.Request = entry.Request.replace(/\n\r?/g, '<br />'));
            entry.CareNote && (entry.CareNote = entry.CareNote.replace(/\n\r?/g, '<br />'));

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

            //console.log('entry', entry);
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
                            $state.go('customerlist', '', { reload: true });
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

    $scope.search = function (searchEntry) {
        $rootScope.showModal = true;

        if (searchEntry.AssignUserId != null && typeof searchEntry.AssignUserId != 'undefined')
            searchEntry.Assign = '1';

        for (var property in searchEntry) {
            if (searchEntry.hasOwnProperty(property)) {
                if (searchEntry[property] == '' || searchEntry[property] == null) {
                    delete searchEntry[property];
                }
            }
        }
        searchEntry.UnAssignedName = tiengvietkhongdau(searchEntry.Name);

        if ($rootScope.searchEntryFilter != null)
            searchEntry = $rootScope.searchEntryFilter;
        else
            $rootScope.searchEntryFilter = searchEntry;


        if (typeof $scope.gridInfo.dtInstance == 'undefined') {
            $timeout(function () {
                showHideColumn();
            }, 1000);
        } else {
            showHideColumn();
        }

        function showHideColumn() {





            //if ($scope.searchEntry.Assign == '1') {
            //    $scope.gridInfo.dtInstance.DataTable.column(4).visible(false);
            //    $scope.gridInfo.dtInstance.DataTable.column(5).visible(false);
            //    //  $scope.gridInfo.dtInstance.DataTable.column(7).visible(false);
            //    $scope.gridInfo.dtInstance.DataTable.column(8).visible(false);
            //    $scope.gridInfo.dtInstance.DataTable.column(9).visible(false);
            //} else {
            //    $scope.gridInfo.dtInstance.DataTable.column(4).visible(true);
            //    $scope.gridInfo.dtInstance.DataTable.column(5).visible(true);
            //    // $scope.gridInfo.dtInstance.DataTable.column(7).visible(true);
            //    $scope.gridInfo.dtInstance.DataTable.column(8).visible(true);
            //    $scope.gridInfo.dtInstance.DataTable.column(9).visible(true);
            //}

            //// console.log('$scope.searchEntry.AssignUserId', $scope.searchEntry.AssignUserId)
            //if ($scope.searchEntry.AssignUserId)
            //    $scope.gridInfo.dtInstance.DataTable.column(7).visible(true);
            //else
            //    $scope.gridInfo.dtInstance.DataTable.column(7).visible(false);

            // hide column delete

            //hide phone
            $scope.gridInfo.dtInstance.DataTable.column(4).visible(false);
            //hide email
            $scope.gridInfo.dtInstance.DataTable.column(5).visible(false);
            $scope.gridInfo.dtInstance.DataTable.column(9).visible(false);
            //hide column edit 
            $scope.gridInfo.dtInstance.DataTable.column(8).visible(false);
            //hide column edit 
            $scope.gridInfo.dtInstance.DataTable.column(7).visible(false);
          
            //hi
            //console.log('$scope.searchEntry.Assign', $scope.searchEntry.Assign, $scope.UserInfo.UserGroupID)
            switch ($scope.UserInfo.UserGroupID) {
                case 0://group 3

                    if ($scope.searchEntry.Assign == '0') {
                        $scope.gridInfo.dtInstance.DataTable.column(4).visible(true);
                        $scope.gridInfo.dtInstance.DataTable.column(5).visible(true);
                        $scope.gridInfo.dtInstance.DataTable.column(7).visible(true);
                        $scope.gridInfo.dtInstance.DataTable.column(8).visible(true);

                    }
                    break;

                case 2://group 2
                    $scope.gridInfo.dtInstance.DataTable.column(4).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(5).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(7).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(8).visible(true);

                    if ($scope.listRight && $scope.listRight.IsDelete && $scope.listRight.IsDelete == 'False')
                        $scope.gridInfo.dtInstance.DataTable.column(9).visible(false);

                    break;
                case 1:// group admin
                    $scope.gridInfo.dtInstance.DataTable.column(4).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(5).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(7).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(8).visible(true);
                    $scope.gridInfo.dtInstance.DataTable.column(9).visible(true);
                    break;
            }
            $scope.gridInfo.dtInstance.DataTable.column(7).visible(false);
            if ($scope.searchEntry.Assign == '0' || typeof $scope.searchEntry.AssignUserId != 'undefined')
                $scope.gridInfo.dtInstance.DataTable.column(7).visible(true);


            $scope.gridInfo.dtInstance.reloadData();

        }

    }

    if ($rootScope.searchEntryFilter != null && typeof $rootScope.searchEntryFilter != 'undefined' && $state.current.url == '/customer-list') {
        $scope.searchEntry = $rootScope.searchEntryFilter;
        //console.log('$scope.searchEntry', $scope.searchEntry);
        $scope.search($scope.searchEntry);

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

.controller('customerDialogCtrl', function ($scope, $rootScope, $modalInstance, customerService, $timeout, coreService, dialogs, $filter, localStorageService) {
    $rootScope.showModal = true;
    $scope.userInfo = localStorageService.get('authorizationData');
    $scope.userList = [];
    $timeout(function () {
        //console.log('customerService', customerService);
        $scope.dataSelected = customerService.dataSelected;
        if (customerService.act == "assign") {
            $rootScope.showModal = true;
            coreService.getListEx({ CustomerID: customerService.CustomerID, Sys_ViewID: 11 }, function (data) {
              //  console.log('CustomerID after', data);
                if (typeof $scope.dataSelected == 'undefined') $scope.dataSelected = {};
                $scope.dataSelected.ID = customerService.CustomerID;
                //console.log('$scope.dataSelected', $scope.dataSelected);
                $scope.userList = data[1];
                $rootScope.showModal = false;
                $scope.$apply();
                //console.log('CustomerID after', data[1]);
            });
        }
        else{
        coreService.getListEx({ CustomerID: customerService.CustomerID, Sys_ViewID: 21 }, function (data) {
            $scope.dataSelected.CareNote = data[2][0].CareNote.replace(/<br \/>/g, '\n');
            //console.log('$scope.dataSelected', $scope.dataSelected);
            $rootScope.showModal = false;
            $scope.$apply();
            //console.log('CustomerID after', data[1]);
        });
        }

       
    }, 2000);

    $scope.title = 'Chỉnh sửa khách hàng';
    $scope.refreshList = false;

    $scope.cancel = function () {
        $modalInstance.dismiss('Canceled');
    }; // end cancel

    $scope.save = function () {
        var act = "UPDATE";
      
        if ($scope.dataSelected.ID != undefined && $scope.dataSelected.ID > 0) act = "UPDATE";
        $scope.actionConfirm(act);
    }; // end save

    $scope.actionConfirm = function (act) {
        $scope.actionEntry(act);
    }

    $scope.actionEntry = function (act) {
        $scope.clicked = true;
        console.log('customerService', customerService);
       
        if (typeof act != 'undefined') {
            var entry = {};
            if (customerService.act == "assign") {
                console.log($scope.userList)

                var selectedId = [];
                angular.forEach($scope.userList, function (item, key) {
                    var object = { "UserID": item.ID, "IsChecked": item.Cheked };
                     selectedId.push(object);
                });
                entry.Item = selectedId;
                entry.Sys_ViewID = 11;
                entry.Action = 'UPDATE';
                entry.CustomerID = customerService.CustomerID;
               
                coreService.actionEntry2(entry, function (data) {
                    if (data.Success) {
                        dialogs.notify(data.Message.Name, data.Message.Description);
                        $modalInstance.close();
                    }
                });
                return;
            }
            else {
                entry = angular.copy($scope.dataSelected);
                entry.Action = act;
                entry.Sys_ViewID = 21; //$scope.gridInfo.sysViewID;
                entry.UserGroupID = $scope.userInfo.UserGroupID;
                entry.CareNote && (entry.CareNote = entry.CareNote.replace(/\n\r?/g, '<br />'));
                //            console.log('entry', entry);
            }
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
                      
                        case 'UPDATE':
                            $modalInstance.close($scope.refreshList);
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

})