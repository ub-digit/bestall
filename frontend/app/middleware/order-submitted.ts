export default defineNuxtRouteMiddleware(() => {
  const { orderSubmitted } = useOrder();

  if (!orderSubmitted.value) return;

  throw createError({
    statusCode: 409,
    statusMessage: "Order already submitted",
    fatal: true,
  });
});
