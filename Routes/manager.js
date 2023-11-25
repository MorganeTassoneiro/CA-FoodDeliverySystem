const express = require('express');
const router = express.Router();

const signupCtrl = require('../app/controllers/deliveryman/signupController');
const sessionCtrl = require('../app/controllers/deliveryman/sessionController');
const restaurantsCtrl = require('../app/controllers/deliveryman/restaurantsController');
const menuCtrl = require('../app/controllers/deliveryman/menuController');
const orderCtrl = require('../app/controllers/deliveryman/orderController');
const deliverymanCtrl = require('../app/controllers/deliveryman/deliverymanController');

// const authMiddleware = require('../app/middlewares/auth');

/*
* Public routes
*/

router.post('/signup', signupCtrl.store);
router.post('/session', sessionCtrl.store);

router.get('/restaurants/:digital_address', restaurantsCtrl.index);
router.get('/deliveryman/:id/menu', menuCtrl.index);

// router.use(authMiddleware);

router.post('/deliveryman/:id/order', orderCtrl.store);
router.get('/informations', deliverymanCtrl.index);

module.exports = router;
