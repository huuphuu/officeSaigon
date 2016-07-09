angular.module('indexApp')
.service("customerService", function ($rootScope, $http, coreService, dialogs) {
    var customerService = {};
    customerService.Sys_ViewID = 21;
    customerService.CustomerID = '';
    //    customerService.dataSelected = { CustomerID: customerService.CustomerID, Sys_ViewID: customerService.Sys_ViewID };

    customerService.broadcastCustomerData = function () {
        console.log('customerService.CustomerID', customerService.CustomerID);
        coreService.getListEx({ CustomerID: customerService.CustomerID, Sys_ViewID: customerService.Sys_ViewID }, function (data) {
            customerService.dataSelected = data[1][0];
//            console.log('customerService.dataSelected service', customerService.dataSelected);
        });
        $rootScope.$broadcast('broadcastGetCustomerData');
    }
    return customerService;
})
