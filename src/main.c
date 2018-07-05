
#include <driverlib/gpio.h>
#include <driverlib/ioc.h>
#include <driverlib/prcm.h>
#include <driverlib/systick.h>

#include "board_config.h"

void main(void) {

    /* Power on peripheral domain and spin until ready. */
    PRCMPowerDomainOn(PRCM_DOMAIN_PERIPH);
    while (PRCMPowerDomainStatus(PRCM_DOMAIN_PERIPH) != PRCM_DOMAIN_POWER_ON);

    /* Enable the GPIO peripheral. */
    PRCMPeripheralRunEnable(PRCM_PERIPH_GPIO);

    /* Update any synchronized power registers (i.e. GPIO periph) */
    PRCMLoadSet();
    while (!PRCMLoadGet());

    /* Set the LEDs as GPIO outputs. */
    IOCPinTypeGpioOutput(DIO_LED_R);
    IOCPinTypeGpioOutput(DIO_LED_G);

    /* Set up initial LED state. */
    GPIO_setDio(DIO_LED_R);
    GPIO_clearDio(DIO_LED_G);

    /* Set SysTick to fire every so often. */
    SysTickPeriodSet(CPU_CLOCK_SPEED / 5);
    SysTickIntEnable();
    SysTickEnable();

    /* Go into a WFI loop while SysTick toggles GPIOs. */
    while(true) {
        PRCMSleep();
    }
}

static bool LedToToggle;

void SysTickIntHandler(void) {

    GPIO_toggleDio(LedToToggle ? DIO_LED_R : DIO_LED_G);
    LedToToggle = !LedToToggle;
}
