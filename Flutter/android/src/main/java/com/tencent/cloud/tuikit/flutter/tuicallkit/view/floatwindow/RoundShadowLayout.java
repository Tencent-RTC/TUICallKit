package com.tencent.cloud.tuikit.flutter.tuicallkit.view.floatwindow;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.graphics.Xfermode;
import android.graphics.Bitmap.Config;
import android.graphics.Paint.Style;
import android.graphics.Path.Direction;
import android.graphics.Path.Op;
import android.graphics.PorterDuff.Mode;
import android.graphics.drawable.BitmapDrawable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import kotlin.jvm.internal.Intrinsics;
import kotlin.ranges.RangesKt;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public final class RoundShadowLayout extends FrameLayout {
    private final float[] radiusArray;

    private Paint mShadowPaint;
    private RectF mShadowRect;
    private Path  mShadowPath;
    private float mShadowRadius;
    private int   mShadowColor;
    private float mShadowX;
    private float mShadowY;
    private float mRoundRadius;
    private Paint mRoundPaint;
    private RectF mRoundRect;
    private Path  mRoundPath;

    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = 0;
        int height = 0;

        for (int i = 0; i < getChildCount(); ++i) {
            View child = getChildAt(i);
            Intrinsics.checkNotNullExpressionValue(child, "child");
            ViewGroup.LayoutParams lp = child.getLayoutParams();
            int childWidthSpec = FrameLayout.getChildMeasureSpec(widthMeasureSpec - (int) mShadowRadius * 2, 0,
                    lp.width);
            int childHeightSpec = FrameLayout.getChildMeasureSpec(heightMeasureSpec - (int) mShadowRadius * 2, 0,
                    lp.height);
            measureChild(child, childWidthSpec, childHeightSpec);
            ViewGroup.LayoutParams var10000 = child.getLayoutParams();
            if (var10000 == null) {
                throw new NullPointerException("null cannot be cast to non-null type android.view.ViewGroup" +
                        ".MarginLayoutParams");
            }

            MarginLayoutParams mlp = (MarginLayoutParams) var10000;
            int childWidth = child.getMeasuredWidth() + mlp.leftMargin + mlp.rightMargin;
            int childHeight = child.getMeasuredHeight() + mlp.topMargin + mlp.bottomMargin;
            width = RangesKt.coerceAtLeast(width, childWidth);
            height = RangesKt.coerceAtLeast(height, childHeight);
        }

        setMeasuredDimension(width + getPaddingLeft() + getPaddingRight() + (int) mShadowRadius * 2,
                height + getPaddingTop() + getPaddingBottom() + (int) mShadowRadius * 2);
    }

    protected void onSizeChanged(int width, int height, int oldw, int oldh) {
        super.onSizeChanged(width, height, oldw, oldh);
        if (width > 0 && height > 0 && mShadowRadius > (float) 0) {
            setBackgroundCompat(width, height);
        }
    }

    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        int i = 0;

        for (int var7 = getChildCount(); i < var7; ++i) {
            View child = getChildAt(i);
            Intrinsics.checkNotNullExpressionValue(child, "child");
            ViewGroup.LayoutParams var10000 = child.getLayoutParams();
            if (var10000 == null) {
                throw new NullPointerException("null cannot be cast to non-null type android.view.ViewGroup" +
                        ".MarginLayoutParams");
            }

            MarginLayoutParams lp = (MarginLayoutParams) var10000;
            int lc = (int) mShadowRadius + lp.leftMargin + getPaddingLeft();
            int tc = (int) mShadowRadius + lp.topMargin + getPaddingTop();
            int rc = lc + child.getMeasuredWidth();
            int bc = tc + child.getMeasuredHeight();
            child.layout(lc, tc, rc, bc);
        }
    }

    protected void dispatchDraw(@Nullable Canvas canvas) {
        mRoundRect.set(mShadowRadius, mShadowRadius, (float) getWidth() - mShadowRadius,
                (float) getHeight() - mShadowRadius);
        Intrinsics.checkNotNull(canvas);
        canvas.saveLayer(mRoundRect, (Paint) null, Canvas.ALL_SAVE_FLAG);
        super.dispatchDraw(canvas);
        mRoundPath.reset();
        mRoundPath.addRoundRect(mRoundRect, radiusArray, Direction.CW);
        clipRound(canvas);
        canvas.restore();
    }

    private void clipRound(Canvas canvas) {
        mRoundPaint.setColor(-1);
        mRoundPaint.setAntiAlias(true);
        mRoundPaint.setStyle(Style.FILL);
        mRoundPaint.setXfermode((Xfermode) (new PorterDuffXfermode(Mode.DST_OUT)));
        Path path = new Path();
        path.addRect(0.0F, 0.0F, (float) getWidth(), (float) getHeight(), Direction.CW);
        path.op(mRoundPath, Op.DIFFERENCE);
        canvas.drawPath(path, mRoundPaint);
    }

    private void setBackgroundCompat(int width, int height) {
        Bitmap bitmap = createShadowBitmap(width, height, mShadowRadius, mShadowX, mShadowY, mShadowColor);
        BitmapDrawable drawable = new BitmapDrawable(getResources(), bitmap);
        setBackground(drawable);
    }

    private Bitmap createShadowBitmap(int shadowWidth, int shadowHeight, float shadowRadius, float dx, float dy,
                                      int shadowColor) {
        Bitmap var10000 = Bitmap.createBitmap(shadowWidth, shadowHeight, Config.ARGB_8888);
        Intrinsics.checkNotNullExpressionValue(var10000, "Bitmap.createBitmap(shad… Bitmap.Config.ARGB_8888)");
        Bitmap output = var10000;
        Canvas canvas = new Canvas(output);
        mShadowRect.set(shadowRadius, shadowRadius, (float) shadowWidth - shadowRadius,
                (float) shadowHeight - shadowRadius);
        RectF tempShadowRect = mShadowRect;
        tempShadowRect.top += dy;
        tempShadowRect = mShadowRect;
        tempShadowRect.bottom -= dy;
        tempShadowRect = mShadowRect;
        tempShadowRect.left += dx;
        tempShadowRect = mShadowRect;
        tempShadowRect.right -= dx;
        mShadowPaint.setAntiAlias(true);
        mShadowPaint.setStyle(Style.FILL);
        mShadowPaint.setColor(shadowColor);
        if (!isInEditMode()) {
            mShadowPaint.setShadowLayer(shadowRadius, dx, dy, shadowColor);
        }

        mShadowPath.reset();
        mShadowPath.addRoundRect(mShadowRect, radiusArray, Direction.CW);
        canvas.drawPath(mShadowPath, mShadowPaint);
        return output;
    }

    public RoundShadowLayout(@NotNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        radiusArray = new float[8];
        mShadowRadius = 10.0F;
        mRoundRadius = 40.0F;
        mShadowColor = Color.argb(255, 187, 187, 187);

        for (int i = 0; i < radiusArray.length; ++i) {
            radiusArray[i] = mRoundRadius;
        }

        mRoundPaint = new Paint();
        mRoundPath = new Path();
        mRoundRect = new RectF();
        mShadowRect = new RectF();
        mShadowPath = new Path();
        mShadowPaint = new Paint();
    }

    public RoundShadowLayout(@NotNull Context context) {
        this(context, null);
    }
}
