<?php

/**
 * The Initial Developer of the Original Code is
 * Tarmo Alexander Sundström <ta@sundstrom.im>
 *
 * Portions created by the Initial Developer are
 * Copyright (C) 2014 Tarmo Alexander Sundström <ta@sundstrom.im>
 *
 * All Rights Reserved.
 *
 * Contributor(s):
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

namespace ValoaApplication\Controllers\Register;

use Libvaloa\Debug;
use Libvaloa\Controller\Redirect;

use Webvaloa\Configuration;
use Webvaloa\Cache;
use Webvaloa\User;
use Webvaloa\Role;
use Webvaloa\Mail\Mail;

use stdClass;
use Exception;
use InvalidArgumentException;
use UnexpectedValueException;

class RegisterController extends \Webvaloa\Application
{
    private $cache;
    private $user;
    private $mail;
    public $message;

    public function __construct()
    {
        $this->cache = new Cache;
    }

    public function index()
    {
        if ($tmp = $this->cache->registration) {
            foreach ($tmp as $k => $v) {
                $this->view->$k = $v;
            }
        }
    }

    public function register()
    {
        Debug::__print($_POST);

        // Cache post
        $this->cache->registration = $_POST;

        // Validate inputs
        $require = array(
            'firstname',
            'lastname',
            'email',
            'confirm_email'
        );

        foreach ($require as $k => $v) {
            if (!isset($_POST[$v]) || empty($_POST[$v])) {
                $this->ui->addError(\Webvaloa\Webvaloa::translate('SOMETHING_MISSING'));
                Redirect::to('register');
            }
        }

        $email = trim($_POST['email']);
        $confirm = trim($_POST['confirm_email']);

        if ($email != $confirm) {
            $this->ui->addError(\Webvaloa\Webvaloa::translate('EMAILS_DONT_MATCH'));
            Redirect::to('register');
        }

        if (!\Webvaloa\User::usernameAvailable($email)) {
            $this->ui->addError(\Webvaloa\Webvaloa::translate('USERNAME_TAKEN'));
            Redirect::to('register');
        }

        // Check for site configuration
        $configuration = new Configuration();

        $admin = $configuration->webmaster_email->value;
        if (empty($admin)) {
            $this->ui->addError(\Webvaloa\Webvaloa::translate('WEBMASTER_EMAIL_NOT_SET'));
            Redirect::to('register');
        }

        $sitename = $configuration->sitename->value;
        if (empty($sitename)) {
            $this->ui->addError(\Webvaloa\Webvaloa::translate('SITENAME_NOT_SET'));
            Redirect::to('register');
        }

        // All good beyond this point

        // Hash for verification
        $hash = sha1(time() . rand(0, 9) . microtime());

        // Create user
        $user = new User;
        $user->login = $user->email = $email;

        if (isset($_SESSION['locale']) && !empty($_SESSION['locale'])) {
            $user->locale = $_SESSION['locale'];
        } else {
            $user->locale = 'en_US';
        }

        $user->firstname = $_POST['firstname'];
        $user->lastname = $_POST['firstname'];
        $user->password = null;
        $user->blocked = 1;

        $meta = new stdClass;
        $meta->token = $hash;
        $user->meta = json_encode($meta);

        // Insert user
        $userID = $user->save();

        // Add registered role for the user
        $user = new User($userID);

        $role = new Role;
        $user->addRole($role->getRoleID('Registered'));

        // Url for verifying the account
        $link = $this->request->getBaseUri() . '/register/verify/' . base64_encode($userID . ":" . $hash);

        // Allow overriding the message with plugins
        if (!isset($this->message) || empty($this->message)) {
            $this->message = \Webvaloa\Webvaloa::translate('VERIFY_ACCOUNT_MAIL_1');
            $this->message.= "<br><br>";
            $this->message.= '<a href="' . $link . '"> ' . \Webvaloa\Webvaloa::translate('VERIFY_ACCOUNT') . ' </a>';
            $this->message.= "<br><br>";
            $this->message.= \Webvaloa\Webvaloa::translate('VERIFY_ACCOUNT_MAIL_2');
        }

        try {
            $mailer = new Mail();
            $send = $mailer->setTo($email, $_POST['firstname'] . ' ' . $_POST['lastname'])
                    ->setSubject(\Webvaloa\Webvaloa::translate('REGISTRATION_CONFIRM'))
                    ->setFrom($admin, $sitename)
                    ->addGenericHeader('X-Mailer', 'Webvaloa')
                    ->addGenericHeader('Content-Type', 'text/html; charset="utf-8"')
                    ->setMessage($this->message)
                    ->setWrap(100)
                    ->send();

            $val = (string) $send;

            if (!$val) {
                $this->ui->addError(\Webvaloa\Webvaloa::translate('MAIL_SENDING_FAILED'));
                Redirect::to('register');
            }
        } catch (\InvalidArgumentException $e) {
            Debug::__print('Sending failed');
            Debug::__print($e->getMessage());
            Debug::__print($e);

            $this->ui->addError(\Webvaloa\Webvaloa::translate('MAIL_SENDING_FAILED'));
            Redirect::to('register');
        } catch (\Exception $e) {
            $this->ui->addError($e->getMessage());
            Redirect::to('register');
        }

        Redirect::to('register/info');
    }

    public function info()
    {
    }

    public function verify($hash = false)
    {
        $this->view->hash = $hash;

        if (!$hash) {
            throw new UnexpectedValueException($this->ui->addError(\Webvaloa\Webvaloa::translate('HASH_MISSING')));
        }

        $data = explode(':', base64_decode($hash));
        $user = new User((int) $data[0]);
        $meta = $user->meta;
        $meta = json_decode($meta);

        if (!isset($meta->token) || empty($meta->token) || $meta->token != $data[1]) {
            throw new UnexpectedValueException($this->ui->addError(\Webvaloa\Webvaloa::translate('HASH_NOT_MATCH')));
        }

        if ($user->blocked != 1) {
            throw new UnexpectedValueException($this->ui->addError(\Webvaloa\Webvaloa::translate('PASSWORD_ALREADY_SET')));
        }

        Debug::__print($meta);
        Debug::__print($data);

        // Token matches

        if (isset($_POST['password'])) {
            if (!isset($_POST['password']) || empty($_POST['password']) || strlen($_POST['password']) < 8) {
                $this->ui->addError(\Webvaloa\Webvaloa::translate('PASSWORD_TOO_SHORT'));
                Redirect::to('register/verify/' . $hash);
            }

            if (!isset($_POST['password2']) || $_POST['password'] != $_POST['password2']) {
                $this->ui->addError(\Webvaloa\Webvaloa::translate('CHECK_PASSWORD'));
                Redirect::to('register/verify/' . $hash);
            }

            // All good, set password and unblock the user
            $user->password = $_POST['password'];
            $user->blocked = 0;
            $meta->token = "";
            $user->meta = json_encode($meta);
            $user->save();

            $this->ui->addMessage(\Webvaloa\Webvaloa::translate('READY'));

            Redirect::to(\Webvaloa\config::$properties['default_controller']);
        }

    }

}