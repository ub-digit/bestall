export default defineNuxtRouteMiddleware(() => {
  const { orderSubmitted } = useOrder();

  if (!orderSubmitted.value) return;

  throw createError({
    statusCode: 409,
    fatal: true,
    data: {
      data: {
        errors: {
          errors: [{ code: "ORDER_ALREADY_SUBMITTED" }],
        },
      },
    },
  });
});
